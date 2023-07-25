@tool
extends PopupPanel


signal name_submitted( sequence_name: String )


@onready var line_edit := %"LineEdit" as LineEdit


func _on_line_edit_text_submitted( new_text: String ) -> void:
	
	hide()
	name_submitted.emit( new_text )


func _on_confirm_button_pressed() -> void:
	
	hide()
	name_submitted.emit( line_edit.text )
