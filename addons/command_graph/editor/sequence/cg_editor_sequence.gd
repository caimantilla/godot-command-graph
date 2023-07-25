@tool
extends Control


const Board := preload ("sub_nodes/board.gd" )
const ENTRYPOINT_EDIT = preload( "sub_nodes/entrypoint_edit.tscn" )


## The sequence this board controls.
var sequence: CG_Sequence = CG_Sequence.new()

## Map of editors currently open, or whatever else...
## Passed to each command node.
var context: Dictionary = {}

var is_loading: bool = false
var bottom_options: HFlowContainer = null

@onready var board := %"Board" as Board
@onready var command_creation_dialog = %"CommandCreationDialog"
@onready var command_creation_tree = command_creation_dialog.get_node( "CommandCreationTree" )


var _command_scene_cache: Dictionary = {}

# I don't like having to store in a member variable, but this is where the next new command will be instantiated.
# Also, maybe make it so that it ends up being offset by half the size of the node
# Not important right now though
var _next_node_instantiation_offset = Vector2.ZERO

var _entrypoint_edit = null




func _exit_tree():
	
	_remove_entrypoint_edit()



func refresh() -> void:
	
	for node in board.get_children( true ):
		if node is CG_EditorCommand:
			node.queue_free()
	
	_command_scene_cache.clear()
	
	for command in sequence.get_command_list():
		
		add_command( command )
	
	refresh_connection_lines()


func add_command( p_command: CG_Command ) -> CG_EditorCommand:
	
	if not p_command:
		return null
	
	var editor_command: CG_EditorCommand = null
	var editor_command_scene_path: String = p_command.editor_get_scene_path()
	
	if not _command_scene_cache.has( editor_command_scene_path ):
		
		if not ResourceLoader.exists( editor_command_scene_path, "PackedScene" ):
			return null
		
		var packed_scene := ResourceLoader.load( editor_command_scene_path, "PackedScene" ) as PackedScene
		if not packed_scene.can_instantiate():
			return null
		
		var instance = packed_scene.instantiate( PackedScene.GEN_EDIT_STATE_DISABLED )
		if not instance is CG_EditorCommand:
			instance.queue_free()
			return null
		
		_command_scene_cache[editor_command_scene_path] = packed_scene
		editor_command = instance as CG_EditorCommand
	
	else:
		
		var packed_scene = _command_scene_cache[editor_command_scene_path] as PackedScene
		editor_command = packed_scene.instantiate( PackedScene.GEN_EDIT_STATE_DISABLED ) as CG_EditorCommand
	
	if not is_instance_valid( editor_command ):
		return null
	
	
	editor_command.close_request.connect( erase_command.bind(p_command.get_id()) )
	
	
	board.add_child( editor_command, false, Node.INTERNAL_MODE_DISABLED )
	
	editor_command.initialize( p_command )
	
	return editor_command


func refresh_connection_lines() -> void:
	
	var was_loading = is_loading
	is_loading = true
	
#	for connection_info in board.get_connection_list():
#		board.disconnect_node( connection_info["from"], connection_info["from_port"], connection_info["to"], connection_info["to_port"] )
	
	board.clear_connections()
	
	for command_edit in board.get_children():
		if command_edit is CG_EditorCommand:
			var outgoing_connections = command_edit.get_outgoing_connections()
			for s in [ "port", "command" ]:
				if not outgoing_connections.has( s ):
					continue
			for outgoing_connection in outgoing_connections:
				if board.has_node( outgoing_connection["command"] ):
					var target_command_edit = board.get_node( outgoing_connection["command"] )
					if target_command_edit is CG_EditorCommand:
						var input_port = target_command_edit.get_input_port()
						if input_port > -1:
							board.connect_node( command_edit.name, outgoing_connection["port"], target_command_edit.name, input_port )
	
	is_loading = was_loading


func connect_commands( from_command: String, from_port: int, to_command: String ) -> bool:
	
	if is_loading:
		return false
	
	var connection_dictionary = {
		"port": from_port,
		"command": to_command,
	}
	
	var command_edit = get_command_edit( from_command )
	if command_edit:
		command_edit.set_outgoing_connection( connection_dictionary )
		refresh_connection_lines()
		return true
	
	return false


func erase_command_connection( on_command: String, at_port: int ) -> void:
	
	if is_loading:
		return
	
	var command_edit = get_command_edit( on_command )
	if command_edit:
		command_edit.set_outgoing_connection( {"port": at_port, "command": ""} )
		refresh_connection_lines()



func get_command_edit( command_id: String ) -> CG_EditorCommand:
	
	var path = NodePath( command_id )
	
	if board and board.has_node( path ):
		return board.get_node( path )
	
	return null



func synchronize_command_resources() -> void:
	
	for child in board.get_children():
		if child is CG_EditorCommand:
			child.synchronize()



# Returns a new command object
# The PATH must be passed, not the script instance.
func _instantiate_command_script_from_path( command_script_path ):
	
	if not ResourceLoader.exists( command_script_path, "Script" ):
		return null
	
	var command_script = load( command_script_path )
	var command = command_script.new()
	
	return command as CG_Command



# Whenever an item is picked in the command dialog basically
func _on_command_creation_tree_command_chosen( command_name, command_script_path ):
	
	const COMMAND_ID_LENGTH: int = 6
	
	var command = _instantiate_command_script_from_path( command_script_path )
	
	if command:
		
		var command_auto_id := CML_UniqueIdentifierUtilities.generate_alphanumeric_id( COMMAND_ID_LENGTH, sequence.commands )
		# If a unique ID couldn't be generated, an empty string is returned (as of 7/9/2023)
		if command_auto_id.is_empty():
			printerr( "Fail!" )
		else:
			
			command.graph_position = _next_node_instantiation_offset
			command.set_id( command_auto_id )
			
			if sequence.register_command( command ):
				
				var editor_command = add_command( command )
#				editor_command.initialize( command ) # already done in add_command
			
			else:
				printerr( "REGISTARTION FAILEDD!!" )
	
	command_creation_dialog.hide()




func _on_board_popup_request( p_position ):
	
	# Only do this shit if it's invisible! damn!!!
#	if not command_creation_dialog.visible:
	if true:
		# The editor command will be instantiated where the mouse clicked
		_next_node_instantiation_offset = p_position + board.scroll_offset
		# Hack, this SHOULD apply itself :(
		if not is_zero_approx( board.zoom ):
			_next_node_instantiation_offset /= board.zoom
		
		_trigger_add_command_dialog()




func _on_board_connection_request( from_node, from_port, to_node, to_port ):
	
	if not is_loading:
		connect_commands( from_node, from_port, to_node )


func _on_board_connection_to_empty( from_node, from_port, release_position ):
	
	if not is_loading:
		erase_command_connection( from_node, from_port )
	
#	var from = board.get_node( from_node as String )
#	_next_node_instantiation_offset = release_position
#
#	_trigger_add_command_dialog()


func _trigger_add_command_dialog() -> void:
	
	var popup_position = get_global_mouse_position() - ( command_creation_dialog.size * 0.5 )
	var popup_rect = Rect2i( popup_position, command_creation_dialog.size )
	
	command_creation_dialog.popup( popup_rect )
	command_creation_tree.grab_focus()


func _on_board_disconnection_request( from_node, from_port, to_node, to_port ):
	
	if not is_loading:
		erase_command_connection( from_node, from_port )




func _on_board_delete_nodes_request( nodes ):
	
	for node_name in nodes:
		erase_command( node_name )


func erase_command( command_id: String ) -> void:
	
	var command_edit = get_command_edit( command_id )
	sequence.unregister_command( command_id )
	
	if command_edit:
		board.remove_child( command_edit )
		command_edit.queue_free()
	
	refresh_connection_lines()


func _on_visibility_changed():
	
	if sequence and is_instance_valid( bottom_options ):
		if visible:
			_add_entrypoint_edit()
		else:
			_remove_entrypoint_edit()


func _add_entrypoint_edit():
	
	if is_instance_valid( _entrypoint_edit ):
		return
	
	_entrypoint_edit = ENTRYPOINT_EDIT.instantiate( PackedScene.GEN_EDIT_STATE_DISABLED )
	bottom_options.add_child( _entrypoint_edit )
	
	_entrypoint_edit.line_edit.text = sequence.get_entrypoint()
	_entrypoint_edit.line_edit.expand_to_text_length = true
	_entrypoint_edit.line_edit.text_changed.connect( sequence.set_entrypoint )


func _remove_entrypoint_edit():
	
	if is_instance_valid( _entrypoint_edit ):
		
		_entrypoint_edit.line_edit.text_changed.disconnect( sequence.set_entrypoint )
#		_entrypoint_edit.get_parent().remove_child( _entrypoint_edit )
		_entrypoint_edit.queue_free()
		_entrypoint_edit = null
