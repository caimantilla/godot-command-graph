tool
extends "res://addons/command_graph/abstract/command_graph_node.gd"


onready var comment_text_edit = get_node("Comment Box")


func _initialize():
	comment_text_edit.set_text(command.get_comment_string())


func _synchronize():
	command.set_comment_string(comment_text_edit.get_text())
