@tool
extends CG_Command


const StateUtilities := preload( "utilities/state.gd" )
const ComparisonUtilities := preload( "utilities/comparison.gd" )

const ComparisonOperator := ComparisonUtilities.ComparisonOperator


## The path to take if the variable evaluates to true.
@export var next_command_id_true: String = ""

## The path to take if the variable evaluates to false.
@export var next_command_id_false: String = ""

## The expression used for the comparison
@export var expression_string: String = ""


func _execute( runtime ):
	
	var state = CG_CommandState.new()
	
#	var evaluation_result = ComparisonUtilities.evaluate( left_value, comparison_operator, right_value )
	var evaluation_result = true # Need to figure out expressions, not rn
	
	if evaluation_result:
		state.finish( next_command_id_true )
	else:
		state.finish( next_command_id_false )
	
	return state




static func editor_get_instantiable():
	
	return true


static func editor_get_id():
	
	return "expression_branch"


static func editor_get_name():
	
	return "Expression Branch"


static func editor_get_category():
	
	return [ "Logic" ]


static func editor_get_scene_path():
	
	return "res://addons/command_graph/base/editors/expression_branch.tscn"
