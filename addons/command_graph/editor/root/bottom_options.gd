@tool
extends HFlowContainer


signal new_sequence_requested()

## Requests removal of the currently focused sequence.
signal sequence_removal_requested()


@onready var button_add_sequence := $"AddSequence" as Button
@onready var button_remove_sequence := $"RemoveSequence" as Button
@onready var removal_confirmation_dialog := $"Windows/RemovalConfirmationDialog" as ConfirmationDialog



func _ready():
	
	button_add_sequence.icon = get_theme_icon( "Add", "EditorIcons" )
	button_remove_sequence.icon = get_theme_icon( "Remove", "EditorIcons" )



func _on_add_sequence_pressed() -> void:
	
	new_sequence_requested.emit()


func _on_remove_sequence_pressed() -> void:
	
	removal_confirmation_dialog.popup_centered()





func _on_removal_confirmation_dialog_confirmed() -> void:
	
	sequence_removal_requested.emit()


func _on_add_name_popup_name_submitted( sequence_name: String ) -> void:
	
	new_sequence_requested.emit( sequence_name )
