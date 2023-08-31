tool
extends Node


const CommandThread = preload("res://addons/command_graph/execute/command_thread.gd")


signal finished()


## The dependencies passed.
## This can be extended to add game-specific dependencies.
var dependencies = null
var sequence = null
var threads = []


func _init(p_dependencies = null, p_sequence = null):
	if p_dependencies == null or p_sequence == null:
		printerr("CommandRuntime requires valid dependencies and sequence objects to initialize.")
		return
	dependencies = p_dependencies
	sequence = p_sequence
	if not dependencies.is_inside_tree():
		dependencies.set_name("Dependencies")
		add_child(dependencies, true)


func notify_finished():
	emit_signal("finished")


func is_finished():
	return threads.empty()


func execute(from_command_id = ""):
	if dependencies == null or sequence == null:
		notify_finished()
		return
	
	if not sequence.has_command(from_command_id):
		printerr("Command \"%s\" not found." % str(from_command_id))
		return
	
	_start_new_thread(from_command_id)


func _start_new_thread(from_command_id):
	if sequence.has_command(from_command_id):
		var thread = CommandThread.new(dependencies, sequence)
		thread.set_name("Thread %d" % (threads.size() + 1))
		add_child(thread, true)
		
		thread.connect("finished", self, "_handle_thread_finish")
		thread.start(from_command_id)
	
	return null


func _handle_thread_finish():
	for i in range(threads.size() - 1, -1, -1):
		var thread = threads[i]
		if thread.is_finished():
			threads.remove(i)
			thread.queue_free()
	
	if is_finished():
		notify_finished()
