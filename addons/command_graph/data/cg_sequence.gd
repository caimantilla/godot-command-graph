@tool
class_name CG_Sequence
extends Resource



const PROPERTY_ENTRYPOINT: Dictionary = {
	"type": TYPE_DICTIONARY,
	"name": "entrypoint",
	"hint": PROPERTY_HINT_NONE,
	"hint_string": "",
	"usage": PROPERTY_USAGE_STORAGE | PROPERTY_USAGE_NO_EDITOR,
}

const PROPERTY_COMMANDS: Dictionary = {
	"type": TYPE_DICTIONARY,
	"name": "commands",
	"hint": PROPERTY_HINT_NONE,
	"hint_string": "",
	"usage": PROPERTY_USAGE_STORAGE | PROPERTY_USAGE_NO_EDITOR,
}



var entrypoint: String = "": set = set_entrypoint, get = get_entrypoint

var commands: Dictionary = {}



func _get_property_list() -> Array [Dictionary]:
	
	var properties: Array [Dictionary] = []
	
	properties.append( PROPERTY_ENTRYPOINT )
	properties.append( PROPERTY_COMMANDS )
	
	return properties





func set_id( p_id: String ) -> void:
	
	resource_name = p_id


func get_id() -> String:
	
	return resource_name



func set_entrypoint( p_entrypoint: String ) -> void:
	
	entrypoint = p_entrypoint


func get_entrypoint() -> String:
	
	return entrypoint



func has_command( command_id: String ) -> bool:
	
	return commands.has( command_id )


func get_command( command_id: String ) -> CG_Command:
	
	if has_command( command_id ):
		return commands[command_id]
	return null


func get_command_list() -> Array [CG_Command]:
	
	var command_list: Array [CG_Command] = []
	command_list.assign( commands.values() )
	
	return command_list


func rename_command( current_id: String, new_id: String ) -> bool:
	
	if new_id.is_empty() \
	or not has_command( current_id ) \
	or has_command( new_id ):
		return false
	
	# Update references to the command that's being renamed.
	for command in get_command_list():
		command.update_references_to_command( current_id, new_id )
	
	var command_to_rename := commands[current_id] as CG_Command
	
	commands.erase( current_id )
	command_to_rename.set_id( new_id )
	commands[new_id] = command_to_rename
	
	return true


func register_command( p_command: CG_Command ) -> bool:
	
	var command_id := p_command.get_id()
	
	if command_id.is_empty() or has_command( command_id ):
		return false
	
	commands[command_id] = p_command
	return true


func unregister_command( p_command_id: String) -> bool:
	
	if not has_command( p_command_id ):
		return false
	
	commands.erase( p_command_id )
	
	# Setting each reference to an empty string should effectively nullify all references to the command.
	for command in get_command_list():
		command.update_references_to_command( p_command_id, "" )
	
	return true
