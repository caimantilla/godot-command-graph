@tool
class_name CommandRuntime
extends Node


signal finished()


## The dependencies passed.
## This can be extended to add game-specific dependencies.
var dependencies: CommandDependencies = null
var sequence: CommandSequence = null
var threads: Array[CommandThread] = []


func _init(p_dependencies: CommandDependencies = null, p_sequence: CommandSequence = null) -> void:
	if p_dependencies == null or p_sequence == null:
		printerr("CommandRuntime requires valid dependencies and sequence objects to initialize.")
		return
	dependencies = p_dependencies
	sequence = p_sequence
	if not dependencies.is_inside_tree():
		dependencies.name = "Dependencies"
		add_child(dependencies, true, Node.INTERNAL_MODE_DISABLED)


func notify_finished() -> void:
	finished.emit()


func is_finished() -> bool:
	return threads.is_empty()


func execute(from_command: String = "") -> void:
	if dependencies == null or sequence == null:
		notify_finished()
		return
	
	if from_command.is_empty():
		from_command = sequence.default_entrypoint_id
	
	if not sequence.has_command(from_command):
		print_debug('Command "' + str(from_command) + '" not found.')
		return
	
	_start_new_thread(from_command)


func _start_new_thread(from_command_id: String) -> CommandThread:
	if sequence.has_command(from_command_id):
		var thread = CommandThread.new(dependencies, sequence)
		thread.name = "Thread %d" % (threads.size() + 1)
		add_child(thread, true, INTERNAL_MODE_DISABLED)
		
		thread.finished.connect(_handle_thread_finish)
		thread.start(from_command_id)
	
	return null


func _handle_thread_finish() -> void:
	for i in range(threads.size() - 1, -1, -1):
		var thread := threads[i]
		if thread.is_finished():
			threads.remove_at(i)
			thread.queue_free()
	
	if is_finished():
		notify_finished()
