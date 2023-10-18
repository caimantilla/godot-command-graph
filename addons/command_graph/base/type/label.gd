@tool
extends CG_Command


@export var next_command_id: String = ""


static func get_editor_id():
	return "label"

static func get_editor_name():
	return "Label"

static func get_editor_description():
	return "A named point in the sequence.\nUnlike other commands, the ID changes to match the name given."

static func get_editor_scene_path():
	return "res://addons/command_graph/base/node/label.tscn"


func _update_command_references(from, to):
	if (from == next_command_id):
		next_command_id = to


func _execute(dependencies):
	var state = CG_CommandState.new()
	state.finish(next_command_id)
	return state
