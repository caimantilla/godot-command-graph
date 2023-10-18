@tool
extends CG_Command


@export var next_command_id: String = ""
@export_range(0.01, 999.9) var seconds: float = 1.0
@export var ignore_time_scale: bool = false


static func get_editor_id():
	return "wait_timer"

static func get_editor_name():
	return "Wait Timer"

static func get_editor_description():
	return "Waits a set number of seconds before proceeding."

static func get_editor_scene_path():
	return "res://addons/command_graph/base/node/wait_timer.tscn"


func _execute(dependencies):
	var state = CG_CommandState.new()
	
	if is_zero_approx(seconds) or seconds < 0.0:
		state.finish(next_command_id)
	else:
		var timer = dependencies.tree.create_timer(seconds, true, false, ignore_time_scale)
		timer.timeout.connect(state.finish.bind(next_command_id), CONNECT_ONE_SHOT)
	
	return state


func _update_command_references(from, to):
	if from == next_command_id:
		next_command_id = to
