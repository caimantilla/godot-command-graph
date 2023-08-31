tool
extends Resource
## A stateless command.
## Provided reference to the game state, manipulating it based on its parameters.
## Should never store any state. CommandState is used for that purpose.


## Emitted when the command's ID changes.
signal id_changed(from, to)


const CommandState = preload("res://addons/command_graph/execute/command_state.gd")


## The command's horizontal position in the graph.
## Only relevant to the editor.
export(int) var graph_position_x = 0 setget set_graph_position_x, get_graph_position_x

## The command's vertical position in the graph.
## Only relevant to the editor.
export(int) var graph_position_y = 0 setget set_graph_position_y, get_graph_position_y


## Sets the command's ID.
func set_id(id):
	if get_name() != id:
		var old = get_name()
		set_name(id)
		emit_signal("id_changed", old, id)

## Returns the command's ID.
func get_id():
	return get_name()


func set_graph_position_x(value):
	graph_position_x = int(value)

func get_graph_position_x():
	return graph_position_x

func set_graph_position_y(value):
	graph_position_y = int(value)

func get_graph_position_y():
	return graph_position_y



static func get_editor_id():
	return "command"

## Virtual function which returns the command's name.
static func get_editor_name():
	return "Abstract Command"

## Virtual function which returns the command's description.
static func get_editor_description():
	return "The base for commands."

## Virtual function which returns the path to the CommandGraphNode scene used to edit the command.
static func get_editor_scene_path():
	return ""


## Virtual function which is called on each of the sequence's commands whenever a command's ID changes (or it's deleted, if "to" is blank).
## All references to the command should be updated, if any are found.
func update_command_references(from, to):
	pass


## Virtual function which begins execution, returning the state of the command.
func execute(dependencies):
	printerr("Can't execute an abstract command.")
	var state = CommandState.new()
	state.finish("")
	return state
