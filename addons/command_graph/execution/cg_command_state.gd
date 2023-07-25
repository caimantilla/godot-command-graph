@tool
class_name CG_CommandState
extends RefCounted


signal finished( p_next_command_id: String )


var _is_finished: bool = false

var _next_command_id: String = ""



func finish( p_next_command_id: String ) -> void:
	
	if not p_next_command_id.is_empty():
		_next_command_id = p_next_command_id
	
	_is_finished = true
	finished.emit( _next_command_id )



func is_finished() -> bool:
	
	return _is_finished


func get_next_command_id() -> String:
	
	return _next_command_id
