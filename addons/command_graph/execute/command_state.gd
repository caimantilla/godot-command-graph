tool
extends Node


signal finished()
signal new_threads_requested()


var _finished = false
var _next_command_id = ""
var _new_thread_command_ids = []


func finish(next_command_id):
	_finished = true
	_next_command_id = next_command_id
	
	emit_signal("finished")


func is_finished():
	return _finished

func get_next_command_id():
	return _next_command_id


func get_new_thread_command_ids():
	return _new_thread_command_ids


func start_new_threads(command_ids):
	_new_thread_command_ids = command_ids
	emit_signal("new_threads_requested")
