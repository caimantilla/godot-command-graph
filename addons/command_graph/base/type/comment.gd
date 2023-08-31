tool
extends "res://addons/command_graph/abstract/command.gd"


export(String, MULTILINE) var comment_string = "" setget set_comment_string, get_comment_string


static func get_editor_id():
	return "comment"

static func get_editor_name():
	return "Comment"

static func get_editor_description():
	return "Provides a space to write notes."

static func get_editor_scene_path():
	return "res://addons/command_graph/base/node/comment.tscn"


func set_comment_string(value):
	comment_string = value

func get_comment_string():
	return comment_string
