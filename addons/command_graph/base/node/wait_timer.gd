tool
extends "res://addons/command_graph/abstract/command_graph_node.gd"


onready var seconds_spinbox = get_node("Seconds Spinbox")


func _initialize():
	seconds_spinbox.set_value(command.get_seconds())


func _synchronize():
	command.set_seconds(seconds_spinbox.get_value())




func _get_input_slot():
	return 0

func _set_outgoing_connection(outgoing_connection):
	if outgoing_connection["slot"] == 0:
			command.set_next_command_id(outgoing_connection["command"])

func _get_outgoing_connections():
	return [
		{
			"slot": 0,
			"command": command.get_next_command_id(),
		}
	]


func _on_Seconds_Spinbox_value_changed( value ):
	synchronize()
