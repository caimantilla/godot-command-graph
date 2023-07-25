@tool
extends CG_EditorCommand


@onready var expression_edit = %"ExpressionEdit"


func _initialize():
	
	expression_edit.text = command.expression_string


func _synchronize():
	
	command.expression_string = expression_edit.text


func _set_outgoing_connection( p_outgoing_connection ):
	
	if p_outgoing_connection["slot"] == 0:
		command.next_command_id = p_outgoing_connection["command"]


func _get_outgoing_connections():
	
	if command.next_command_id.is_empty():
		return []
	
	return [
		{
			"slot": 0,
			"command": command.next_command_id,
		},
	]


func _get_input_slot():
	
	return 0
