@tool
extends RefCounted






enum VariableScope {
	NONE = 0,
	LOCAL = 1,
	GLOBAL = 2,
}







static func validate_variable_storage( p_runtime: CG_Runtime ) -> bool:
	
	if "locals" in p_runtime.context \
	and "globals" in p_runtime.context \
	and typeof( p_runtime.context["locals"] ) == TYPE_DICTIONARY \
	and typeof( p_runtime.context["globals"] ) == TYPE_DICTIONARY:
		return true
	
	return false


static func get_variable_scope( p_runtime: CG_Runtime, variable_identifier: Variant ) -> VariableScope:
	
	if validate_variable_storage( p_runtime ):
		
		if variable_identifier in p_runtime.context["locals"]:
			return VariableScope.LOCAL
		
		if variable_identifier in p_runtime.context["globals"]:
			return VariableScope.GLOBAL
	
	return VariableScope.NONE



static func has_variable( p_runtime: CG_Runtime, variable_identifier: Variant ) -> bool:
	
	return get_variable_scope( p_runtime, variable_identifier ) != VariableScope.NONE


static func get_variable( p_runtime: CG_Runtime, variable_identifier: Variant ) -> Variant:
	
	match get_variable_scope( p_runtime, variable_identifier ):
		VariableScope.LOCAL:
			return p_runtime.context["locals"][variable_identifier]
		VariableScope.GLOBAL:
			return p_runtime.context["globals"][variable_identifier]
	
	return null


static func set_local( p_runtime: CG_Runtime, variable_identifier: Variant, variable_value: Variant ) -> void:
	
	if validate_variable_storage( p_runtime ):
		p_runtime.context["locals"][variable_identifier] = variable_value


static func set_global( p_runtime: CG_Runtime, variable_identifier: Variant, variable_value: Variant ) -> void:
	
	if validate_variable_storage( p_runtime ):
		p_runtime.context["globals"][variable_identifier] = variable_value


static func set_variable( p_runtime: CG_Runtime, variable_identifier: Variant, variable_value: Variant ) -> void:
	
	if not validate_variable_storage( p_runtime ):
		return
	
	match get_variable_scope( p_runtime, variable_identifier ):
		VariableScope.GLOBAL:
			set_global( p_runtime, variable_identifier, variable_value )
		_:
			set_local( p_runtime, variable_identifier, variable_value )
