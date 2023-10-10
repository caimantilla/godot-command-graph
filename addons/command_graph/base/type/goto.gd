@tool
extends CG_Command


@export var next_command_id: String = ""


static func _get_editor_id():
	return "label"

static func _get_editor_name():
	return "Label"

static func _get_editor_description():
	return "An anchor for deciding where to go next.\nThis might be used for clarity, or as a termination point for other branches."

static func _get_editor_scene_path():
	return "res://addons/command_graph/base/node/goto.tscn"


func _update_command_references(from, to):
	if (from == next_command_id):
		next_command_id = to


func _execute(dependencies):
	var state = CG_CommandState.new()
	state.finish(next_command_id)
	return state
