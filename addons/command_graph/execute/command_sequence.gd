tool
extends Resource
## A collection of commands.


const Command = preload("res://addons/command_graph/abstract/command.gd")


signal command_added(command)
signal removing_command(command)


export(Dictionary) var _commands = {}



func get_commands():
	return _commands.values()


func has_command(id):
	return _commands.has(id)


func get_command(id):
	if has_command(id):
		return _commands[id]
	return null


func add_command(command):
	var id = command.get_id()
	if id == "" or has_command(id):
		id = _generate_new_id()
		command.set_id(id)
	
	_commands[command.get_id()] = command
	emit_signal("command_added", command)


func remove_command(command):
	if typeof(command) == TYPE_STRING:
		command = get_command(command)
	
	if not command extends Command:
		print_debug("Failed to remove command. The value retrieved is: " + str(command))
		return false
	
	var id = command.get_id()
	if not has_command(id):
		print_debug("A command was passed, but couldn't be found, so it can't be removed.")
		return false
	
	emit_signal("removing_command", command)
	_commands.erase(id)
	notify_command_id_changed(id, "")
	
	return true


func notify_command_id_changed(from, to):
	for command in get_commands():
		command.update_command_references(from, to)


func _generate_new_id():
	for i in range(1, 9999, 1):
		var id = "COM_%04d" % i
		if not has_command(id):
			return id
	return "ERROR"
