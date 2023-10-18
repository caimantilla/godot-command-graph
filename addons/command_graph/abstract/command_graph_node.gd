@tool
class_name CG_CommandGraphNode
extends GraphNode


signal close_request()


enum NodeState {
	EMPTY = 0,
	SAFE = 1,
	INITIALIZING = 2,
	SYNCHRONIZING = 3,
}


var plugin: CG_EditorPlugin = null

var command: CG_Command = null

var _node_state := NodeState.EMPTY



func _notification(what: int) -> void:
	if what == NOTIFICATION_THEME_CHANGED:
		update_styling()



########
# Notifiers

func notify_close_request() -> void:
	close_request.emit()



######
# public functions

func initialize() -> void:
	if plugin == null or command == null:
		return
	
	_node_state = NodeState.INITIALIZING
	
	var dpi_scale: float = 1.0
	if plugin != null and Engine.is_editor_hint():
		#dpi_scale = plugin.get_editor_interface().get_editor_scale()
		dpi_scale = EditorInterface.get_editor_scale()
	
	
	name = command.get_id()
	@warning_ignore("static_called_on_instance")
	title = "%s (%s)" % [command.get_editor_name(), command.get_id()]
	position_offset.x = command.graph_position_x * dpi_scale
	position_offset.y = command.graph_position_y * dpi_scale
	
	_initialize()
	
	# Rather than connect the signal on each command node scene, better just do it here
	if not position_offset_changed.is_connected(synchronize):
		position_offset_changed.connect(synchronize)
	
	var close_button = Button.new()
	close_button.pressed.connect(notify_close_request)
	close_button.size_flags_horizontal = Control.SIZE_SHRINK_END
	close_button.icon = get_theme_icon("RemoveInternal", "EditorIcons")
	get_titlebar_hbox().add_child(close_button)
	
	_node_state = NodeState.SAFE
	update_styling()


func synchronize() -> void:
	if plugin == null or command == null:
		return
	
	if _node_state != NodeState.SAFE:
		return
	
	_node_state = NodeState.SYNCHRONIZING
	
	
	var dpi_scale: float = 1.0
	if plugin != null and Engine.is_editor_hint():
		#dpi_scale = plugin.get_editor_interface().get_editor_scale()
		dpi_scale = EditorInterface.get_editor_scale()
	
	command.graph_position_x = roundi(position_offset.x / dpi_scale)
	command.graph_position_y = roundi(position_offset.y / dpi_scale)
	
	_synchronize()
	
	_node_state = NodeState.SAFE


func update_styling() -> void:
	if _node_state == NodeState.SAFE:
		_update_styling()


func get_input_slot() -> int:
	return _get_input_slot()

func get_input_port() -> int:
	return input_get_port_from_slot(get_input_slot())



## Returns the outgoing connections based on the state of the command.
## Each entry needs to contain the "slot" and "command" properties.
func get_outgoing_connections() -> Array:
	var outgoing_connections = []
	
	if command != null and _node_state == NodeState.SAFE:
		outgoing_connections.append_array(_get_outgoing_connections())
	
	for outgoing_connection in outgoing_connections:
		if "slot" in outgoing_connection:
			outgoing_connection["port"] = output_get_port_from_slot(outgoing_connection["slot"])
	
	return outgoing_connections


func set_outgoing_connection(outgoing_connection) -> void:
	outgoing_connection["slot"] = output_get_slot_from_port(outgoing_connection["port"])
	print(outgoing_connection)
	_set_outgoing_connection(outgoing_connection)



# Utility!!

func input_get_slot_from_port(port: int) -> int:
	var slot: int = get_input_port_slot(port)
	# REFER TO output_get_slot_from_port() COMMENTS
	slot -= 1
	return slot


func input_get_port_from_slot(slot: int) -> int:
	var port: int = slot
	#var open_count: int = get_input_port_count()
	
	for i in range(slot):
		if not is_slot_enabled_left(i):
			port -= 1
	
	return port


func output_get_slot_from_port(port: int) -> int:
	var slot: int = get_output_port_slot(port)
	# TODO: WHAT THE FUCK HAPPENED IN 4.2??? WHY IS THE SLOT RETURNING 1 WHEN THE PORT IS 0 WTF WTF WTF
	# ANYWAYS SEE IF DECREMENTING FIXES IT........ LITERALLY WTF
	slot -= 1
	return slot


func output_get_port_from_slot(slot: int) -> int:
	var port: int = slot
	#var open_count: int = get_output_port_count()
	
	for i in slot:
		if not is_slot_enabled_right(i):
			port -= 1
	
	return port



###############################
# Virtuals below


func _initialize() -> void:
	pass


func _synchronize() -> void:
	pass


func _update_styling() -> void:
	pass


func _get_input_slot() -> int:
	return -1


func _get_outgoing_connections() -> Array:
	return []


func _set_outgoing_connection(_outgoing_connection) -> void:
	pass
