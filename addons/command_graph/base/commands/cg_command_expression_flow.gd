@tool
class_name CG_Command_ExpressionFlow
extends CG_Command


@export var expression_string: String = ""
@export var next_command_id: String = ""




func _execute( runtime ):
	
	var state = CG_CommandState.new()
	state.finish( next_command_id )
	
	# Still need to learn the expression class, it's all a bit specific anyways
	
	return state




static func editor_get_instantiable():
	
	return true


static func editor_get_id():
	
	return "expression_flow"


static func editor_get_name():
	
	return "Expression"


static func editor_get_category():
	
	return [ "Logic" ]


static func editor_get_scene_path():
	
	return "res://addons/command_graph/base/editors/expression_flow.tscn"
