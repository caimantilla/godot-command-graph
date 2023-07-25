@tool
extends CG_EditorCommand


const Command_ExpressionBranch = preload( "res://addons/command_graph/base/commands/expression_branch.gd" )


const ComparisonUtilities = preload( "res://addons/command_graph/base/commands/utilities/comparison.gd" )
const ComparisonOperator = ComparisonUtilities.ComparisonOperator
const COMPARISON_OPERATOR_STRING = ComparisonUtilities.COMPARISON_OPERATOR_STRING



@onready var expression_edit = %"ExpressionEdit"
@onready var expression_edit_margin_container = %"ExpressionEditMarginContainer"

@onready var true_label = %"TrueLabel"
@onready var false_label = %"FalseLabel"


func _ready():
	
	super()
	
	if not Engine.is_editor_hint() or get_tree().edited_scene_root != self:
		_update_expression_edit_size()


func _initialize():
	
	expression_edit.text = command.expression_string


func _synchronize():
	
	command.expression_string = expression_edit.text


func _update_expression_edit_size():
	
	var margin = maxf( true_label.size.x, false_label.size.x )
	
	expression_edit_margin_container.add_theme_constant_override( "margin_right", margin )


func _get_input_slot():
	
	return 0


func _get_outgoing_connections():
	
	var outgoing_connections = []
	
	var true_connection = { "slot": 0, "command": command.next_command_id_true }
	var false_connection = { "slot": 2, "command": command.next_command_id_false }
	
	if not true_connection["command"].is_empty():
		outgoing_connections.append( true_connection )
	if not false_connection["command"].is_empty():
		outgoing_connections.append( false_connection )
	
	return outgoing_connections


func _set_outgoing_connection( p_outgoing_connection ):
	
	match p_outgoing_connection["slot"]:
		0:
			command.next_command_id_true = p_outgoing_connection["command"]
		2:
			command.next_command_id_false = p_outgoing_connection["command"]
