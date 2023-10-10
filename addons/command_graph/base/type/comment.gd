@tool
extends CG_Command


@export_multiline var comment_string: String = ""


static func _get_editor_id():
	return "comment"

static func _get_editor_name():
	return "Comment"

static func _get_editor_description():
	return "Provides a space to write notes."

static func _get_editor_scene_path():
	return "res://addons/command_graph/base/node/comment.tscn"
