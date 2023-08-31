tool
extends EditorPlugin


const CommandSequence = preload("res://addons/command_graph/execute/command_sequence.gd")


const PROJECT_SETTING_COMMAND_SCRIPT_PATHS = "command_graph/config/command_script_paths"
const _DEFAULT_COMMAND_SCRIPT_PATHS = [
	"res://addons/command_graph/base/type/comment.gd",
	"res://addons/command_graph/base/type/wait_timer.gd",
]

const CommandSequenceEditor = preload("res://addons/command_graph/editor/command_sequence_editor.tscn")


var sequence_editor = null


func _enter_tree():
	add_custom_type("CommandSequence", "Resource", CommandSequence, null)
	
	var paths = _DEFAULT_COMMAND_SCRIPT_PATHS
	
	if not Globals.has(PROJECT_SETTING_COMMAND_SCRIPT_PATHS):
		Globals.set(PROJECT_SETTING_COMMAND_SCRIPT_PATHS, paths)
		Globals.set_persisting(PROJECT_SETTING_COMMAND_SCRIPT_PATHS, true)
	
	sequence_editor = CommandSequenceEditor.instance()
	sequence_editor.set_plugin(self)
	
	add_control_to_bottom_panel(sequence_editor, "Command Sequence")


func _exit_tree():
	remove_custom_type("CommandSequence")
	
	remove_control_from_bottom_panel(sequence_editor)
	sequence_editor.queue_free()


func handles(object):
	if object extends CommandSequence:
		return true


func edit(object):
	if object extends CommandSequence:
		if sequence_editor != null and sequence_editor.get_sequence() != object:
			sequence_editor.load_sequence(object)
#		make_bottom_panel_item_visible(sequence_editor)


func save_external_data():
	if sequence_editor != null:
		var sequence = sequence_editor.get_sequence()
		if sequence != null:
			if ResourceLoader.has(sequence.get_path()):
				ResourceSaver.save(sequence.get_path(), sequence)


func get_command_script_paths():
	var paths = null
	
	if Globals.has(PROJECT_SETTING_COMMAND_SCRIPT_PATHS):
		paths = Globals.get(PROJECT_SETTING_COMMAND_SCRIPT_PATHS)
	
	if paths == null:
		paths = []
	
	return paths
