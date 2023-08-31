tool
extends MarginContainer


const Command = preload("res://addons/command_graph/abstract/command.gd")
const CommandSequence = preload("res://addons/command_graph/execute/command_sequence.gd")
const CommandGraphNode = preload("res://addons/command_graph/abstract/command_graph_node.gd")


var plugin = null setget set_plugin, get_plugin
var sequence = null setget set_sequence, get_sequence


export(NodePath) var no_sequence_label_path = NodePath()
export(NodePath) var sequence_container_path = NodePath()
export(NodePath) var graph_edit_path = NodePath()
export(NodePath) var command_creation_popup_path = NodePath()


onready var no_sequence_label = get_node(no_sequence_label_path)
onready var sequence_container = get_node(sequence_container_path)
onready var graph_edit = get_node(graph_edit_path)
onready var command_creation_popup = get_node(command_creation_popup_path)


var _command_nodes = {}
var _currently_loading = false
var _next_node_instantiation_offset = Vector2(0, 0)
var _connection_erasure_queue = []




func set_plugin(value):
	plugin = value

func get_plugin():
	return plugin


func set_sequence(value):
	sequence = value

func get_sequence():
	return sequence




func _ready():
	if command_creation_popup extends PopupMenu:
		command_creation_popup.set_plugin(plugin)
	if graph_edit != null:
		graph_edit.set_right_disconnects(true)
	
#	if not get_tree().is_editor_hint():
#		var timer = Timer.new()
#		timer.set_autostart(true)
#		timer.set_wait_time(1)
#		add_child(timer)
#		yield(timer, "timeout")
#		timer.queue_free()
#		
#		var script = load("res://addons/command_graph/base/type/wait_timer.gd")
#		var com1 = script.new()
#		var com2 = script.new()
#		var com3 = script.new()
#		com2.set_graph_position_x(50)
#		com3.set_graph_position_y(60)
#		com2.set_next_command_id("COM_0003")
#		var seq = load("res://event/day_00/first_meet_901/sequence/seq_01.tres")
#		var seq = CommandSequence.new()
#		seq.add_command(com1)
#		seq.add_command(com2)
#		seq.add_command(com3)
#		load_sequence(seq)


func is_loading():
	return _currently_loading


func load_sequence(p_sequence):
	if p_sequence == null:
		unload_sequence()
		return
	
	sequence = p_sequence
	
	no_sequence_label.hide()
	sequence_container.show()
	
	reload_nodes()


func unload_sequence():
	sequence = null
	
	sequence_container.hide()
	no_sequence_label.show()


func has_command_node(command):
	if typeof(command) == TYPE_OBJECT and command extends Command:
		command = command.get_id()
	return _command_nodes.has(command)


func get_command_node(command):
	if typeof(command) == TYPE_OBJECT and command extends Command:
		command = command.get_id()
	if _command_nodes.has(command):
		return _command_nodes[command]
	return null


func get_command_nodes():
	return _command_nodes.values()


func reload_nodes():
	_currently_loading = true
	
	for connection in graph_edit.get_connection_list():
		graph_edit.disconnect_node(connection["from"], connection["from_port"], connection["to"], connection["to_port"])
	
	for node in _command_nodes.values():
		node.queue_free()
	_command_nodes.clear()
	
	if sequence == null:
		return
	
	for command in sequence.get_commands():
		var command_scene_path = command.get_editor_scene_path()
		if true:
		# This wasn't working for some reason...? Just make sure your path is valid, the plugin won't be able to check.
#		if ResourceLoader.has(command_scene_path):
			var command_scene = load(command_scene_path)
			if true:
#			if command_scene extends PackedScene:
				
				var command_node = command_scene.instance()
				command_node.set_plugin(plugin)
				command_node.set_command(command)
				
				graph_edit.add_child(command_node, false)
#				command_node.release_focus()
#				command_node.show()
				
				_command_nodes[command.get_id()] = command_node
				
				command_node.initialize()
				
				command_node.connect("close_request", self, "erase_command", [command])
	
	_currently_loading = false
	
	for command_node in get_command_nodes():
		var outgoing_connections = command_node.get_outgoing_connections()
		for outgoing_connection in outgoing_connections:
			for property in ["port", "command"]:
				if not outgoing_connections.has(property):
					continue
			
			var target_command_node = get_command_node(outgoing_connection["command"])
			
			if target_command_node != null:
				var input_port = target_command_node.get_input_port()
				if input_port > -1:
					graph_edit.connect_node(command_node.get_name(), outgoing_connection["port"], target_command_node.get_name(), input_port)
	
	
#	reload_connection_lines()


func reload_connection_lines():
	reload_nodes()
#	# GraphEdit.clear_connections() isn't available in Godot 2
#	
#	var was_loading = _currently_loading
#	_currently_loading = true
#	
#	graph_edit.clear_connections()
#	
#	for command_node in get_command_nodes():
#		var outgoing_connections = command_node.get_outgoing_connections()
#		
#		for outgoing_connection in outgoing_connections:
#			for property in ["port", "command"]:
#				if not property in outgoing_connection:
#					continue
#			
#			var target_command_node = get_command_node(outgoing_connection["command"])
#			if target_command_node != null:
#				var input_port = target_command_node.get_input_port()
#				if input_port > -1:
#					graph_edit.connect_node(command_node.get_name(), outgoing_connection["port"], target_command_node.get_name(), input_port)
#	
#	_currently_loading = was_loading


func add_command(command):
	if sequence != null:
		command.set_graph_position_x(round(_next_node_instantiation_offset.x))
		command.set_graph_position_y(round(_next_node_instantiation_offset.y))
		sequence.add_command(command)
#		print_debug(command, command.get_id())
		reload_nodes()


func erase_command(command):
	if sequence != null:
		if sequence.remove_command(command):
			reload_nodes()


func create_connection(from_command, from_port, to_command):
	if is_loading():
		return false
	
	var connection_dictionary = {
		"port": from_port,
		"command": to_command.get_id() if to_command != null else "",
	}
	
	var from_command_node = get_command_node(from_command)
	if from_command_node == null:
		return false
	
	from_command_node.set_outgoing_connection(connection_dictionary)
	reload_connection_lines()
	return true


func erase_connection(command, at_port):
	if is_loading():
		return
	
	var command_node = get_command_node(command)
	if command_node != null:
		command_node.set_outgoing_connection({"port": at_port, "command": ""})
		reload_connection_lines()


func _process_connection_erasure_queue():
	if is_loading():
		return
	
	for connection in _connection_erasure_queue:
		var command = connection["command"]
		var slot = connection["slot"]
		var command_node = get_command_node(command)
		if command_node != null:
			command_node.set_outgoing_connection({"port": slot, "command": ""})
	reload_connection_lines()




func synchronize_commands():
	for command_node in get_command_nodes():
		command_node.synchronize()





func prompt_command_creation_popup():
	command_creation_popup.initialize()
	
	command_creation_popup.popup()
	var popup_position = get_global_mouse_pos() - (command_creation_popup.get_size() * 0.5)
#	var popup_rect = Rect2i(popup_position, command_creation_popup.size)
	
	command_creation_popup.set_pos(popup_position)
#	command_creation_popup.grab_focus()


func _create_command_from_script(script):
	var instance = script.new()
	if instance extends Command:
		add_command(instance)
	else:
		# Delete if the class instanced extends Object
		if instance != null and not instance extends Reference:
			instance.free()



func _on_graph_edit_popup_request(at_position):
	at_position = graph_edit.get_local_mouse_pos()
	_next_node_instantiation_offset = at_position + graph_edit.get_scroll_ofs()
	print("The position clicked is %s." % str(at_position))
	print("The scroll offset is %s." % str(graph_edit.get_scroll_ofs()))
	print("The next CommandGraphNode instantiation offset is %s." % str(_next_node_instantiation_offset))
	
	if graph_edit.get_zoom() > 0.01:
		_next_node_instantiation_offset /= graph_edit.get_zoom()
	
#	if plugin != null:
#		var dpi_scale = plugin.get_editor_interface().get_editor_scale()
#		if not is_zero_approx(dpi_scale):
#			_next_node_instantiation_offset *= dpi_scale
	
	_next_node_instantiation_offset = Vector2(
		round(_next_node_instantiation_offset.x),
		round(_next_node_instantiation_offset.y)
	)
	
	prompt_command_creation_popup()


func _on_graph_edit_connection_request(from_node, from_port, to_node, to_port):
	var origin_node = graph_edit.get_node(from_node)
	var target_node = graph_edit.get_node(to_node)
	
	var origin_command = origin_node.get_command()
	var target_command = target_node.get_command()
	
	create_connection(origin_command, from_port, target_command)


#func _on_graph_edit_connection_to_empty(from_node, from_port, release_position):
#	var origin_node = graph_edit.get_node(from_node)
#	var origin_command = origin_node.get_command()
#	
#	erase_connection(origin_command, from_port)


func _on_graph_edit_disconnection_request(from_node, from_slot, to_node, to_slot):
	var origin_node = graph_edit.get_node(from_node)
	var origin_command = origin_node.get_command()
	
	_connection_erasure_queue.append({"command": origin_command, "slot": from_slot})
	if not get_tree().is_connected("idle_frame", self, "_process_connection_erasure_queue"):
		get_tree().connect("idle_frame", self, "_process_connection_erasure_queue", [], CONNECT_ONESHOT)
