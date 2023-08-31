tool
extends PopupMenu


signal command_selected(command_script)


var plugin = null setget set_plugin, get_plugin


func set_plugin(value):
	plugin = value

func get_plugin():
	return plugin


func initialize():
	clear()
	
	if plugin == null:
		return
	
	var scripts = []
	var script_paths = plugin.get_command_script_paths()
#	print("Getting paths.")
	for path in script_paths:
		scripts.append(load(path))
	
	for i in range(scripts.size()):
		var script = scripts[i]
		if script == null:
			continue
		# Pray it extends Command
		var command_name = script.get_editor_name()
		add_item(str(command_name), i)
		set_item_metadata(i, script.get_path())


func _on_index_pressed(index):
	var path = get_item_metadata(index)
	var script = load(path)
	if script != null:
		print("Successfully loaded")
		emit_signal("command_selected", script)
