@tool
class_name CommandState
extends Node


signal finished()
signal new_threads_requested()


var _finished: bool = false
var _next_command_id: String = ""
var _new_thread_command_ids: PackedStringArray = PackedStringArray()


func finish(next_command_id: String) -> void:
	_finished = true
	_next_command_id = next_command_id
	
	finished.emit()


func is_finished() -> bool:
	return _finished

func get_next_command_id() -> String:
	return _next_command_id


func get_new_thread_command_ids() -> PackedStringArray:
	return _new_thread_command_ids


func start_new_threads(command_ids: PackedStringArray) -> void:
	_new_thread_command_ids = command_ids
	new_threads_requested.emit()
