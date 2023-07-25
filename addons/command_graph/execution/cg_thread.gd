@tool
class_name CG_Thread
extends Object


signal finished()


var runtime: CG_Runtime = null
var sequence: CG_Sequence = null

var current_command_id: String = ""
var current_command_state: CG_CommandState = null


func _init( p_runtime: CG_Runtime, p_sequence: CG_Sequence ) -> void:
	
	assert( is_instance_valid(p_runtime), "Can't initialize thread without a reference to the runtime." )
	assert( is_instance_valid(p_sequence), "Can't initialize thread without a reference to a sequence." )
	
	runtime = p_runtime
	sequence = p_sequence


func start( p_new_command_id: String = "" ) -> void:
	
	assert( is_instance_valid(runtime) )
	
	current_command_id = p_new_command_id
	
	if not p_new_command_id.is_empty() and sequence.has_command( p_new_command_id ):
		
		var command := sequence.get_command( p_new_command_id )
		current_command_state = command.execute( runtime )
		
		# Proceed if the action finishes immediately
		if current_command_state.is_finished():
			start( current_command_state.get_next_action_id() )
		else:
			current_command_state.finished.connect( start, CONNECT_ONE_SHOT )
	
	else:
		finished.emit()
