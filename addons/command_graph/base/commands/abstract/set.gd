@tool
extends CG_Command


const StateUtilities := preload( "../utilities/state.gd" )


@export var next_command_id: String = ""


@export var variable_identifier: String = ""
@export var variable_value: String = ""


func execute( p_runtime: CG_Runtime ) -> CG_CommandState:
	
	var state := CG_CommandState.new()
	state.finish( next_command_id )
	
	var value = _get_value( p_runtime )
	
	_set_operation( p_runtime, variable_identifier, value )
	
	return state


func _set_operation( p_runtime: CG_Runtime, identifier: Variant, value: Variant ) -> void:
	
	pass


func _get_value( p_runtime: CG_Runtime ) -> Variant:
	
	if StateUtilities.has_variable( p_runtime, variable_value ):
		return StateUtilities.get_variable( p_runtime, variable_value )
	
	return str_to_var( variable_value )
