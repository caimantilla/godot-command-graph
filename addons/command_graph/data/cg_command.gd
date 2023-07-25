@tool
class_name CG_Command
extends Resource


## Emitted when a reference relevant to this action has been updated.
## Used to more efficiently synchronize the editor state.
signal command_reference_updated( old_id: String, new_id: String )


## The position of the action in the graph board.
## This only matters in-editor.
var graph_position: Vector2 = Vector2.ZERO






func _get_property_list() -> Array[Dictionary]:
	
	var properties: Array [Dictionary] = []
	
	properties.append({
		"type": TYPE_VECTOR2,
		"name": "graph_position",
		"hint": PROPERTY_HINT_NONE,
		"hint_string": "",
		"usage": PROPERTY_USAGE_STORAGE | PROPERTY_USAGE_NO_EDITOR,
	})
	
	return properties







func set_id( p_id: String ) -> void:
	
	resource_name = p_id


func get_id() -> String:
	
	return resource_name









## Virtual.
## Triggers execution and returns an execution state.
func execute( runtime: CG_Runtime ) -> CG_CommandState:
	
	var state: CG_CommandState = _execute( runtime )
	if not state:
		state = CG_CommandState.new()
		state.finish( "" )
	
	return state


func _execute( runtime: CG_Runtime ) -> CG_CommandState:
	
	return null





## Virtual.
## Updates references to any connections, for when an commands is renamed or removed.
func update_references_to_command( _old_command_id: String, _new_command_id: String ) -> void:
	
	pass





## Virtual.
## Mostly applicable for dialogue commands.
func get_translation_metadata_list() -> Array [CG_StringTranslationMetadata]:
	
	var translation_metadata_list: Array [CG_StringTranslationMetadata] = []
	
	return translation_metadata_list



## Returns whether or not the command can be instantiated.
## This should generally be enabled, only leave it as-is for abstract commands.
static func editor_get_instantiable() -> bool:
	
	return false


## Returns the ID of the command.
## Not currently used, but could be used when serializing a command in the future.
## This should match the script's filename.
static func editor_get_id() -> String:
	
	return "cg_command"


## Returns the name displayed to the game designer in-editor.
static func editor_get_name() -> String:
	
	return "CG Base Command"


## Returns the list of categories that the command falls under.
static func editor_get_category() -> PackedStringArray:
	
	return []


## Returns the path to the GraphNode scene corresponding to the command.
static func editor_get_scene_path() -> String:
	
	return ""
