@tool
extends Control


const CG_EDITOR_SEQUENCE_SCENE := preload( "res://addons/command_graph/editor/sequence/cg_editor_sequence.tscn" )
const CG_EditorSequence := preload( "res://addons/command_graph/editor/sequence/cg_editor_sequence.gd" )


var edited_package: CG_Package = null: set = set_edited_package
var edited_sequence: CG_Sequence = null: set = set_edited_sequence


@onready var sequence_tabs := %"SequenceTabs" as TabContainer
@onready var bottom_options := %"BottomOptions" as HFlowContainer

@onready var add_sequence_failed_dialog := $"Windows/AddSequenceFailedDialog" as AcceptDialog
@onready var new_sequence_id_entry_dialog = %"NewSequenceIdEntryDialog"
@onready var new_sequence_id_edit = %"NewSequenceIdEdit"


func initialize( p_command_package: CG_Package ):
	
	edited_package = p_command_package
	refresh_sequences()




func has_sequence( sequence_name: String ) -> bool:
	
	if edited_package:
		return edited_package.has_sequence( sequence_name )
	return false


func get_sequence( sequence_name: String ) -> CG_Sequence:
	
	if edited_package:
		return edited_package.get_sequence( sequence_name )
	return null


func get_sequences() -> Array [CG_Sequence]:
	
	if edited_package:
		return edited_package.get_sequences()
	return []


func refresh_sequences():
	
	var sequences = get_sequences()
	
	_clear_sequence_tabs()
	
	for sequence in sequences:
		_instantiate_new_sequence_tab( sequence )
	
	for child in sequence_tabs.get_children():
		if "sequence" in child:
			if child.sequence == edited_sequence:
				var control_index = sequence_tabs.get_tab_idx_from_control( child )
				sequence_tabs.current_tab = control_index
				break




func set_edited_package( p_edited_package: CG_Package ) -> void:
	
	edited_package = p_edited_package
	if is_node_ready():
		
		var package_validity = is_instance_valid( p_edited_package )
		
		for node in [ bottom_options ]:
			node.visible = package_validity


func set_edited_sequence( p_edited_sequence: CG_Sequence ) -> void:
	
	edited_sequence = p_edited_sequence






func _instantiate_new_sequence_tab( sequence: CG_Sequence ) -> CG_EditorSequence:
	
	if not sequence or sequence.get_id().is_empty():
		return null
	
	var editor_sequence_tab_instance := CG_EDITOR_SEQUENCE_SCENE.instantiate( PackedScene.GEN_EDIT_STATE_DISABLED ) as CG_EditorSequence
	
	editor_sequence_tab_instance.name = sequence.get_id()
	editor_sequence_tab_instance.sequence = sequence
	editor_sequence_tab_instance.bottom_options = bottom_options
	
	sequence_tabs.add_child( editor_sequence_tab_instance )
	editor_sequence_tab_instance.refresh()
	
	return editor_sequence_tab_instance


func _clear_sequence_tabs() -> void:
	
	if sequence_tabs:
		for child in sequence_tabs.get_children( false ):
			child.queue_free()


func _new_sequence_requested() -> void:
	
	new_sequence_id_entry_dialog.popup_centered()


func _sequence_removal_requested() -> void:
	
	if edited_sequence:
		var current_sequence_control = sequence_tabs.get_current_tab_control()
		if current_sequence_control and "sequence" in current_sequence_control:
			if current_sequence_control.sequence == edited_sequence:
				edited_package.erase_sequence( edited_sequence.get_id() )
				current_sequence_control.queue_free()




func _on_new_sequence_id_entry_dialog_confirmed():
	
	if edited_package:
		var new_sequence = edited_package.create_sequence( new_sequence_id_edit.text )
		if new_sequence:
			var sequence_edit = _instantiate_new_sequence_tab( new_sequence )


func _on_new_sequence_id_entry_dialog_about_to_popup():
	
	new_sequence_id_edit.text = ""


func _on_sequence_tabs_tab_changed( tab ):
	
	var tab_control = sequence_tabs.get_tab_control( tab )
	if tab_control and "sequence" in tab_control:
		edited_sequence = tab_control.sequence
