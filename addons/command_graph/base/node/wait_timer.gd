@tool
extends CG_CommandGraphNode


@onready var seconds_spinbox = $SecondsSpinbox
@onready var ignore_time_scale_checkbox = $IgnoreTimeScaleCheckBox


func _initialize():
	seconds_spinbox.value = command.seconds
	ignore_time_scale_checkbox.button_pressed = command.ignore_time_scale
	
	seconds_spinbox.value_changed.connect(synchronize.unbind(1))
	ignore_time_scale_checkbox.toggled.connect(synchronize.unbind(1))


func _synchronize():
	command.seconds = seconds_spinbox.value
	command.ignore_time_scale = ignore_time_scale_checkbox.button_pressed




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
