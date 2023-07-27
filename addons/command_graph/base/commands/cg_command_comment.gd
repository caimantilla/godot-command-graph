@tool
class_name CG_Command_Comment
extends CG_Command


@export var comment_string: String = ""


static func editor_get_instantiable():
	
	return true


static func editor_get_id():
	
	return "comment"


static func editor_get_name():
	
	return "Comment"


static func editor_get_category():
	
	return [ "Logic" ]


static func editor_get_scene_path():
	
	return "res://addons/command_graph/base/editors/comment.tscn"
