@tool
extends MarginContainer


var plugin: CommandGraphEditorPlugin = null

var sequence: CommandSequence = null


@onready var no_sequence_label = %"NoSequenceLabel"

@onready var sequence_container = %"SequenceContainer"

@onready var graph_edit = %"GraphEdit"
@onready var bottom_flow_container = %"BottomFlowContainer"

@onready var command_creation_popup = %"CommandCreationPopup"


var _command_nodes: Dictionary = {}
var _currently_loading: bool = false
var _next_node_instantiation_offset := Vector2.ZERO


func _ready() -> void:
	command_creation_popup.plugin = plugin


func is_loading() -> bool:
	return _currently_loading


func load_sequence(p_sequence: CommandSequence) -> void:
	if p_sequence == null:
		unload_sequence()
		return
	
	sequence = p_sequence
	
	no_sequence_label.hide()
	sequence_container.show()
	
	reload_nodes()


func unload_sequence() -> void:
	sequence = null
	
	sequence_container.hide()
	no_sequence_label.show()


func has_command_node(command) -> bool:
	if command is Command:
		command = command.get_id()
	return _command_nodes.has(command)


func get_command_node(command) -> CommandGraphNode:
	if command is Command:
		command = command.get_id()
	if _command_nodes.has(command):
		return _command_nodes[command] as CommandGraphNode
	return null


func get_command_nodes():
	return _command_nodes.values()


func reload_nodes() -> void:
	for node in get_command_nodes():
		node.queue_free()
	_command_nodes.clear()
	
	if sequence == null:
		return
	
	for command in sequence.get_commands():
		var command_scene_path = command.get_editor_scene_path()
		if ResourceLoader.exists(command_scene_path):
			var command_scene = load(command_scene_path) as PackedScene
			if command_scene != null:
				
				var command_node = command_scene.instantiate() as CommandGraphNode
				command_node.plugin = plugin
				command_node.command = command
				
				
				graph_edit.add_child(command_node)
				_command_nodes[command.get_id()] = command_node
				
				command_node.initialize()
				
				command_node.close_request.connect(erase_command.bind(command))
	
	reload_connection_lines()


func reload_connection_lines() -> void:
	var was_loading = _currently_loading
	_currently_loading = true
	
	graph_edit.clear_connections()
	
	for command_node in get_command_nodes():
		var outgoing_connections = command_node.get_outgoing_connections()
		
		for outgoing_connection in outgoing_connections:
			for property in ["port", "command"]:
				if not property in outgoing_connection:
					continue
			
			var target_command_node = get_command_node(outgoing_connection["command"])
			if target_command_node != null:
				var input_port = target_command_node.get_input_port()
				if input_port > -1:
					graph_edit.connect_node(command_node.name, outgoing_connection["port"], target_command_node.name, input_port)
	
	_currently_loading = was_loading


func add_command(command: Command) -> void:
	if sequence != null:
		command.graph_position_x = roundf(_next_node_instantiation_offset.x)
		command.graph_position_y = roundf(_next_node_instantiation_offset.y)
		sequence.add_command(command)
		print_debug(command, command.get_id())
		reload_nodes()


func erase_command(command: Command) -> void:
	if sequence != null:
		if sequence.remove_command(command):
			reload_nodes()


func create_connection(from_command: Command, from_port: int, to_command: Command) -> bool:
	if is_loading():
		return false
	
	var connection_dictionary: Dictionary = {
		"port": from_port,
		"command": to_command.get_id() if to_command != null else "",
	}
	
	var from_command_node = get_command_node(from_command)
	if from_command_node == null:
		return false
	
	from_command_node.set_outgoing_connection(connection_dictionary)
	reload_connection_lines()
	return true


func erase_connection(command: Command, at_port: int) -> void:
	if is_loading():
		return
	
	var command_node = get_command_node(command)
	if command_node != null:
		command_node.set_outgoing_connection({"port": at_port, "command": ""})
		reload_connection_lines()


func synchronize_commands() -> void:
	for command_node in get_command_nodes():
		command_node.synchronize()


func prompt_command_creation_popup() -> void:
	command_creation_popup.initialize()
	
	var popup_position = get_global_mouse_position() - (command_creation_popup.size * 0.5)
	var popup_rect = Rect2i(popup_position, command_creation_popup.size)
	
	command_creation_popup.popup(popup_rect)
#	command_creation_popup.grab_focus()


func _create_command_from_script(script: Script) -> void:
	var instance = script.new()
	if instance is Command:
		add_command(instance)
	else:
		if instance is Object and not instance is RefCounted:
			instance.free()



func _on_graph_edit_popup_request(at_position: Vector2) -> void:
	
	_next_node_instantiation_offset = at_position + graph_edit.scroll_offset
	
	if not is_zero_approx(graph_edit.zoom):
		_next_node_instantiation_offset /= graph_edit.zoom
	
	if plugin != null:
		var dpi_scale = plugin.get_editor_interface().get_editor_scale()
		if not is_zero_approx(dpi_scale):
			_next_node_instantiation_offset *= dpi_scale
	
	_next_node_instantiation_offset.x = roundf(_next_node_instantiation_offset.x)
	_next_node_instantiation_offset.y = roundf(_next_node_instantiation_offset.y)
	
	prompt_command_creation_popup()


func _on_graph_edit_connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int) -> void:
	var origin_node = graph_edit.get_node(String(from_node))
	var target_node = graph_edit.get_node(String(to_node))
	
	var origin_command = origin_node.command
	var target_command = target_node.command
	
	create_connection(origin_command, from_port, target_command)


func _on_graph_edit_connection_to_empty(from_node: StringName, from_port: int, release_position: Vector2) -> void:
	var origin_node = graph_edit.get_node(String(from_node))
	var origin_command = origin_node.command
	
	erase_connection(origin_command, from_port)
