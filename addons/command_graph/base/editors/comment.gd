@tool
extends CG_EditorCommand


@onready var comment_edit = %"CommentEdit"


func _initialize():
	
	comment_edit.text = command.comment_string


func _synchronize():
	
	command.comment_string = comment_edit.text
