@tool
extends CG_CommandGraphNode


@onready var notes_entry = $Notes


func _initialize():
	notes_entry.text = command.notes_string
	
	notes_entry.text_changed.connect(synchronize.unbind(1))


func _synchronize():
	command.notes_string = notes_entry.text


func _get_input_slot():
	return 0

func _set_outgoing_connection(outgoing_connection):
	if outgoing_connection["slot"] == 0:
			command.next_command_id = outgoing_connection["command"]

func _get_outgoing_connections():
	var outgoing_connections = [
		{
			"slot": 0,
			"command": command.next_command_id,
		}
	]
	
	return outgoing_connections
