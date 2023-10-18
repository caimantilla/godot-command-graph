@tool
class_name CG_Command
extends Resource
## A stateless command.
##
## Provided reference to the game state, manipulating it based on its parameters.
## Should never store any state. CommandState is used for that purpose.


## Emitted when the command's ID changes.
signal id_changed(from: String, to: String)


## The command's horizontal position in the graph.
## Only relevant to the editor.
@export var graph_position_x: int = 0

## The command's vertical position in the graph.
## Only relevant to the editor.
@export var graph_position_y: int = 0


## Sets the command's ID.
func set_id(id: String) -> void:
	if (resource_name != id):
		var old = resource_name
		resource_name = id
		id_changed.emit(old, resource_name)

## Returns the command's ID.
func get_id() -> String:
	return resource_name


## Return's the command type's ID.
static func get_editor_id() -> String:
	return "command"

## Returns the command type's name.
static func get_editor_name() -> String:
	return "INVALID COMMAND"

## Returns the command type's description.
static func get_editor_description() -> String:
	return ""

## Returns the path to the CommandGraphNode scene used to edit the command type.
static func get_editor_scene_path() -> String:
	return ""


## Called on each of the sequence's commands whenever a command's ID changes (or it's deleted, if "to" is blank).
## All references to the command should be updated, if any are found.
func update_command_references(from: String, to: String) -> void:
	_update_command_references(from, to)

## Begins execution, returning the state of the command.
func execute(dependencies: CG_CommandDependencies) -> CG_CommandState:
	return _execute(dependencies)


## Virtual
func _update_command_references(from: String, to: String) -> void:
	pass

## Virtual
func _execute(dependencies: CG_CommandDependencies) -> CG_CommandState:
	assert("Execution function not defined.")
	var state := CG_CommandState.new()
	state.finish("")
	return state
