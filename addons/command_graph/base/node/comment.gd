@tool
extends CommandGraphNode


@onready var comment_text_edit = %"CommentTextEdit"


func _initialize():
	comment_text_edit.text = command.comment_string


func _synchronize():
	command.comment_string = comment_text_edit.text
