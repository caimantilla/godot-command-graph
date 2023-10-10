@tool
class_name CG_CommandThread
extends Node


signal finished()
signal new_thread_requested(start_command_id: String)


var dependencies: CG_CommandDependencies = null
var sequence: CG_CommandSequence = null


var _current_command: CG_Command = null
var _current_command_state: CG_CommandState = null


func _init(p_dependencies: CG_CommandDependencies, p_sequence: CG_CommandSequence) -> void:
	if p_dependencies == null or p_sequence == null:
		printerr("Valid dependencies and sequence objects must be passed when initializing a command thread.")
		return
	
	dependencies = p_dependencies
	sequence = p_sequence


func is_finished() -> bool:
	return _current_command_state == null


func start(from_command_id: String) -> void:
	if _current_command_state != null:
		_current_command_state.finished.disconnect(_process_state_finished)
		_current_command_state.new_threads_requested.disconnect(_process_state_new_threads_requested)
		_current_command_state.queue_free()
	
	_current_command = null
	_current_command_state = null
	
	if not sequence.has_command(from_command_id):
		finished.emit()
		return
	
	_current_command = sequence.get_command(from_command_id)
	_current_command_state = _current_command.execute(dependencies)
	_current_command_state.name = "%s State" % _current_command.get_id()
	add_child(_current_command_state, true)
	
	# If finished immediately, these will be disconnected.
	_current_command_state.finished.connect(_process_state_finished)
	_current_command_state.new_threads_requested.connect(_process_state_new_threads_requested)
	
#	dependencies.tree.create_timer(5.0).timeout.connect(func(): print_debug(_current_command_state.finished.is_connected(_process_state_finished)), CONNECT_ONE_SHOT)
	
	# New threads must be requested before finishing, so request them before calling start in the case that the command finished immediately.
	# If there are no new threads at this time, none should be requested. (23/08/2023)
	_request_new_threads(_current_command_state.get_new_thread_command_ids())
	
	if _current_command_state.is_finished():
		start(_current_command_state.get_next_command_id())


func _request_new_threads(command_ids: PackedStringArray) -> void:
	for command_id in command_ids:
		new_thread_requested.emit(command_id)


func _process_state_finished() -> void:
	if _current_command_state != null:
		var next_command_id = _current_command_state.get_next_command_id()
		start(next_command_id)


func _process_state_new_threads_requested() -> void:
	if _current_command_state != null:
		var command_ids = _current_command_state.get_new_thread_command_ids()
		_request_new_threads(command_ids)
