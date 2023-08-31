tool
extends Node


signal finished()
signal new_thread_requested(start_command_id)


var dependencies = null
var sequence = null


var _current_command = null
var _current_command_state = null


func _init(p_dependencies = null, p_sequence = null):
	if p_dependencies == null or p_sequence == null:
		printerr("Valid dependencies and sequence objects must be passed when initializing a command thread.")
		return
	
	dependencies = p_dependencies
	sequence = p_sequence


func is_finished():
	return _current_command_state == null


func start(from_command_id):
	if _current_command_state != null:
		_current_command_state.disconnect("finished", self, "_process_state_finished")
		_current_command_state.disconnect("new_threads_requested", self, "_process_state_new_threads_requested")
		_current_command_state.queue_free()
	
	_current_command = null
	_current_command_state = null
	
	if not sequence.has_command(from_command_id):
		emit_signal("finished")
		return
	
	_current_command = sequence.get_command(from_command_id)
	_current_command_state = _current_command.execute(dependencies)
	_current_command_state.set_name("%s State" % _current_command.get_id())
	add_child(_current_command_state, true)
	
	# If finished immediately, these will be disconnected.
	_current_command_state.connect("finished", self, "_process_state_finished")
	_current_command_state.connect("new_threads_requested", self, "_process_state_new_threads_requested")
	
#	dependencies.tree.create_timer(5.0).timeout.connect(func(): print_debug(_current_command_state.finished.is_connected(_process_state_finished)), CONNECT_ONE_SHOT)
	
	# New threads must be requested before finishing, so request them before calling start in the case that the command finished immediately.
	# If there are no new threads at this time, none should be requested. (23/08/2023)
	_request_new_threads(_current_command_state.get_new_thread_command_ids())
	
	if _current_command_state.is_finished():
		start(_current_command_state.get_next_command_id())


func _request_new_threads(command_ids):
	for command_id in command_ids:
		emit_signal("new_thread_requested", command_id)


func _process_state_finished():
	if _current_command_state != null:
		var next_command_id = _current_command_state.get_next_command_id()
		start(next_command_id)


func _process_state_new_threads_requested():
	if _current_command_state != null:
		var command_ids = _current_command_state.get_new_thread_command_ids()
		_request_new_threads(command_ids)
