@tool
class_name CG_CommandSequence
extends Resource
## A collection of commands.


signal command_added(command: CG_Command)
signal removing_command(command: CG_Command)


@export var default_entrypoint_id: String = ""
@export var _commands: Dictionary = {}



func get_commands():
	return _commands.values()


func has_command(id: String) -> bool:
	return _commands.has(id)


func get_command(id: String) -> CG_Command:
	if _commands.has(id):
		return _commands[id] as CG_Command
	return null


func add_command(command: CG_Command) -> void:
	var id: String = command.get_id()
	if id.is_empty() or _commands.has(id):
		id = _generate_new_id()
		command.set_id(id)
	
	_commands[command.get_id()] = command
	command_added.emit(command)


func remove_command(command) -> bool:
	match typeof(command):
		TYPE_STRING, TYPE_STRING_NAME:
			command = get_command(command)
	
	if not command is CG_Command:
		print_debug("Failed to remove command. The value retrieved is: " + str(command))
		return false
	
	var id = command.get_id()
	if not _commands.has(id):
		print_debug("A command was passed, but couldn't be found, so it can't be removed.")
		return false
	
	removing_command.emit(command)
	_commands.erase(id)
	notify_command_id_changed(id, "")
	
	return true


func notify_command_id_changed(from: String, to: String) -> void:
	for command in get_commands():
		command.update_command_references(from, to)


func _generate_new_id() -> String:
	# Please make a new sequence if you need more than 9,999 commands. Also, give your hands a break.
	for i in range(1, 9999):
		var id = "COM_%04d" % i
		if not _commands.has(id):
			return id
	return "ERROR"
