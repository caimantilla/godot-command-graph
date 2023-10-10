@tool
class_name CG_EditorPlugin
extends EditorPlugin


const PROJECT_SETTING_COMMAND_SCRIPT_PATHS: String = "command_graph/config/command_script_paths"
const _DEFAULT_COMMAND_SCRIPT_PATHS = [
	"res://addons/command_graph/base/type/comment.gd",
	"res://addons/command_graph/base/type/wait_timer.gd",
]

var CommandSequenceEditor = load("res://addons/command_graph/editor/command_sequence_editor.tscn")


var sequence_editor = null


func _enter_tree() -> void:
	var paths = PackedStringArray(_DEFAULT_COMMAND_SCRIPT_PATHS)
	
	if not ProjectSettings.has_setting(PROJECT_SETTING_COMMAND_SCRIPT_PATHS):
		ProjectSettings.set_setting(PROJECT_SETTING_COMMAND_SCRIPT_PATHS, paths)
	ProjectSettings.set_initial_value(PROJECT_SETTING_COMMAND_SCRIPT_PATHS, paths)
	
	sequence_editor = CommandSequenceEditor.instantiate()
	sequence_editor.plugin = self
	
	add_control_to_bottom_panel(sequence_editor, "Command Sequence")


func _exit_tree() -> void:
	remove_control_from_bottom_panel(sequence_editor)
	sequence_editor.queue_free()


func _handles(object):
	if object is CG_CommandSequence:
		return true


func _edit(object):
	if object is CG_CommandSequence:
		if sequence_editor != null and sequence_editor.sequence != object:
			sequence_editor.load_sequence(object)
		make_bottom_panel_item_visible(sequence_editor)


func _save_external_data():
	if sequence_editor != null:
		var sequence = sequence_editor.sequence
		if sequence != null:
			if ResourceLoader.exists(sequence.resource_path):
				ResourceSaver.save(sequence, sequence.resource_path)


func get_command_script_paths() -> PackedStringArray:
	var paths = null
	
	if ProjectSettings.has_setting(PROJECT_SETTING_COMMAND_SCRIPT_PATHS):
		paths = ProjectSettings.get_setting(PROJECT_SETTING_COMMAND_SCRIPT_PATHS, null)
	
	if typeof(paths) != TYPE_PACKED_STRING_ARRAY:
		paths = PackedStringArray()
	
	return paths
