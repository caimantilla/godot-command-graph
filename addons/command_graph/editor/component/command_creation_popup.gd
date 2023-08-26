@tool
extends PopupMenu


signal command_selected(command_script: Script)


var plugin: CommandGraphEditorPlugin = null


func initialize() -> void:
	clear()
	
	if plugin == null:
		return
	
	var scripts = []
	var script_paths = plugin.get_command_script_paths()
	for path in script_paths:
		if ResourceLoader.exists(path):
			scripts.append(load(path))
	
	for i in scripts.size():
		var script = scripts[i] as Script
		if script == null:
			continue
		# Pray it extends Command
		var command_name = script.get_editor_name()
		add_item(str(command_name), i)
		set_item_metadata(i, script.resource_path)


func _on_index_pressed(index: int) -> void:
	var path = get_item_metadata(index)
	if typeof(path) == TYPE_STRING:
		if ResourceLoader.exists(path):
			var script = load(path) as Script
			if script != null:
				command_selected.emit(script)
