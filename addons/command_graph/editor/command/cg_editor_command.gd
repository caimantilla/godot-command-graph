@tool
class_name CG_EditorCommand
extends GraphNode



enum NodeState {
	EMPTY = 0,
	SAFE = 1,
	INITIALIZING = 2,
	SYNCHRONIZING = 3,
}



## Reference to the Command Graph singleton
## This can be used to access the plugin, or UI root, or interfacing with object outside the plugin...
var cg_singleton = null


## Reference to the command to be edited by this node.
var command: CG_Command = null

## The state of the node to know what can be done at any given time
var _node_state: NodeState = NodeState.EMPTY


func _init() -> void:
	
	pass


func _ready() -> void:
	
	if has_node( "/root/CG_Singleton" ):
		cg_singleton = get_node( "/root/CG_Singleton" )



## Called by the editor right after setting the command.
## This should allow the user to safely initialize the node state from an existing command.
func initialize( p_command: CG_Command ) -> void:
	
	if not p_command:
		printerr( "Command passed must be valid." )
		return
	
	
	_node_state = NodeState.INITIALIZING
	
	
	command = p_command
	
	
	var command_id = p_command.get_id()
	var command_name = p_command.editor_get_name()
	var command_offset = p_command.graph_position
	
	name = command_id
	# Title is the name of the command followed by its ID in parenthesis.
	title = "%s (%s)" % [ command_name, command_id ]
	position_offset = command_offset
	
	
	_initialize()
	
	_node_state = NodeState.SAFE


## Virtual
## Command state should be initialized here
func _initialize() -> void:
	
	pass


func get_node_state() -> NodeState:
	
	return _node_state


## Used to synchronize the state of the command resource with the editor node.
## In other words, it's the opposite of initialize.
## It only works when the command is safe to access.
## This makes it easy to hook up node signals to synchronize to update state without worrying about infinite recursion.
func synchronize() -> void:
	
	if not _node_state == NodeState.SAFE:
		return
	
	_node_state = NodeState.SYNCHRONIZING
	
#	command.set_id( title )
	command.graph_position = position_offset
	
	_synchronize()
	
	_node_state = NodeState.SAFE


## Virtual
func _synchronize() -> void:
	
	pass



func get_input_slot() -> int:
	
	return _get_input_slot()


func _get_input_slot() -> int:
	
	return -1


func get_input_port() -> int:
	
	return input_get_port_from_slot( _get_input_slot() )


## Returns the outgoing connections based on the state of the command.
## Each entry needs to contain the "slot" and "command" properties.
func get_outgoing_connections() -> Array:
	
	var outgoing_connections: Array = []
	
	if command and _node_state == NodeState.SAFE:
		outgoing_connections.append_array( _get_outgoing_connections() )
	
	for outgoing_connection in outgoing_connections:
		if "slot" in outgoing_connection:
			outgoing_connection["port"] = output_get_port_from_slot( outgoing_connection["slot"] )
	
	return outgoing_connections


## Virtual
func _get_outgoing_connections() -> Array:
	
	return []


## Public access for _set_outgoing_connection, doesn't do anything else atm
func set_outgoing_connection( p_outgoing_connection ) -> void:
	
	p_outgoing_connection["slot"] = output_get_slot_from_port( p_outgoing_connection["port"] )
	
	_set_outgoing_connection( p_outgoing_connection )


## Virtual
func _set_outgoing_connection( p_outgoing_connection ) -> void:
	
	pass


#func get_connections_per_slot() -> Array:
#
#	var connections_per_slot = []
#	connections_per_slot.append_array( _get_connections_per_slot() )
#
#	return connections_per_slot
#
#
### Virtual
#func _get_connections_per_slot() -> Array:
#
#	return []



func input_get_slot_from_port( port: int ) -> int:
	
	return get_connection_input_slot( port )


func input_get_port_from_slot( slot: int ) -> int:
	
	var port: int = slot
	var open_count: int = get_connection_input_count()
	
	for i in range( 0, slot, 1 ):
		if not is_slot_enabled_left( i ):
			port -= 1
	
	return port


func output_get_slot_from_port( port: int ) -> int:
	
	return get_connection_output_slot( port )


func output_get_port_from_slot( slot: int ) -> int:
	
	var port: int = slot
	var open_count: int = get_connection_output_count()
	
	for i in range( 0, slot, 1 ):
		if not is_slot_enabled_right( i ):
			port -= 1
	
	return port
