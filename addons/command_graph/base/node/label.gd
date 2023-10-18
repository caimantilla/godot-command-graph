
extends CG_CommandGraphNode
# INCOMPLETE... I FORGOT HOW I WOULD IMPLEMENT THIS


@onready var command_id_edit = $CommandID


func _initialize():
	command_id_edit.text = command.get_id()


func _synchronize():
	var new_id = command_id_edit.text
