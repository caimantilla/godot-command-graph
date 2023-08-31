tool
extends GraphNode


enum NodeState {
	EMPTY = 0,
	SAFE = 1,
	INITIALIZING = 2,
	SYNCHRONIZING = 3,
}


var plugin = null setget set_plugin, get_plugin

var command = null setget set_command, get_command

var _node_state = NodeState.EMPTY



func _notification(what):
	if what == NOTIFICATION_THEME_CHANGED:
		update_styling()


func set_plugin(value):
	plugin = value

func get_plugin():
	return plugin


func set_command(value):
	command = value

func get_command():
	return command


######
# public functions

func initialize():
#	if plugin == null or command == null:
	if command == null:
		return
	
	_node_state = NodeState.INITIALIZING
	
	var dpi_scale = 1.0
#	if plugin != null and Engine.is_editor_hint():
#		dpi_scale = plugin.get_editor_interface().get_editor_scale()
	
	
	set_name(command.get_id())
	set_title("%s (%s)" % [command.get_editor_name(), command.get_id()])
	set_offset(Vector2(command.get_graph_position_x() * dpi_scale, command.get_graph_position_y() * dpi_scale))
	
	_initialize()
	
	# Rather than connect the signal on each command node scene, better just do it here
	if not is_connected("offset_changed", self, "synchronize"):
		connect("offset_changed", self, "synchronize")
	set_show_close_button(true)
	set_h_size_flags(0)
	set_v_size_flags(0)
	
	_node_state = NodeState.SAFE
	update_styling()


func synchronize():
#	if plugin == null or command == null:
	if command == null:
		return
	
	if _node_state != NodeState.SAFE:
		return
	
	_node_state = NodeState.SYNCHRONIZING
	
	
	var dpi_scale = 1.0
#	if plugin != null and Engine.is_editor_hint():
#		dpi_scale = plugin.get_editor_interface().get_editor_scale()
	
	command.set_graph_position_x(round(get_offset().x / dpi_scale))
	command.set_graph_position_y(round(get_offset().y / dpi_scale))
	
	_synchronize()
	
	_node_state = NodeState.SAFE


func update_styling():
	if _node_state == NodeState.SAFE:
		_update_styling()


func get_input_slot():
	return _get_input_slot()

func get_input_port():
	return input_get_port_from_slot(get_input_slot())



## Returns the outgoing connections based on the state of the command.
## Each entry needs to contain the "slot" and "command" properties.
func get_outgoing_connections():
	var outgoing_connections = []
	
	if command != null and _node_state == NodeState.SAFE:
		for outgoing_connection in _get_outgoing_connections():
			outgoing_connections.append(outgoing_connection)
	
	for outgoing_connection in outgoing_connections:
		if outgoing_connection.has("slot"):
			outgoing_connection["port"] = output_get_port_from_slot(outgoing_connection["slot"])
	
	return outgoing_connections


func set_outgoing_connection(outgoing_connection):
	outgoing_connection["slot"] = output_get_slot_from_port(outgoing_connection["port"])
	print("Slot: ", outgoing_connection["slot"], "\nPort: ", outgoing_connection["port"])
	_set_outgoing_connection(outgoing_connection)



# Utility!!

func input_get_slot_from_port(port):
	var input_count = 0
	for child in get_children():
		if child extends Control:
			input_count += 1
	
	var map = {}
	
	var current_port = 0
	
	for current_slot in range(input_count):
		if is_slot_enabled_left(current_slot):
			map[current_port] = current_slot
			current_port += 1
	
	if map.has(port):
		return map[port]
	printerr("Failed to retrieve an input slot form port %02d." % port)
	return -1


func input_get_port_from_slot(slot):
	var port = slot
	
	for i in range(slot):
		if not is_slot_enabled_left(i):
			port -= 1
	
	return port


func output_get_slot_from_port(port):
	var output_count = 0
	for child in get_children():
		if child extends Control:
			output_count += 1
	
	var map = {}
	
	var current_port = 0
	
	for current_slot in range(output_count):
		if is_slot_enabled_right(current_slot):
			map[current_port] = current_slot
			current_port += 1
	
	if map.has(port):
		return map[port]
	printerr("Failed to retrieve an output slot from port %02d" % port)
	return -1


func output_get_port_from_slot(slot):
	var port = slot
	
	for i in range(slot):
		if not is_slot_enabled_right(i):
			port -= 1
	
	return port



###############################
# Virtuals below


func _initialize():
	pass


func _synchronize():
	pass


func _update_styling():
	pass


func _get_input_slot():
	return -1


func _get_outgoing_connections():
	return []


func _set_outgoing_connection(outgoing_connection):
	pass
