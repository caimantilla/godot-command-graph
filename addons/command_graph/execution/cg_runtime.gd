@tool
class_name CG_Runtime
extends Node


signal finished()


@export var package: CG_Package: set = set_package, get = get_package


## Context passed in by the game.
## All default entries are expected to be overriden on initialization!
var context: Dictionary = {
	"globals": {},
	"locals": {},
}

## Active execution threads.
var threads: Array [CG_Thread] = []




func set_package( p_package: CG_Package ) -> void:
	
	package = p_package


func get_package() -> CG_Package:
	
	return package





## Executes the sequence passed.
## An entrypoint can also be passed, though by default the entrypoint defined in the sequence will be used.
func execute( p_sequence_id: String, p_entrypoint_id: String = "" ) -> CG_Thread:
	
	if not is_instance_valid( package ):
		finished.emit()
		return null
	
	if not package.has_sequence( p_sequence_id ):
		finished.emit()
		return null
	
	var sequence := package.get_sequence( p_sequence_id )
	
	var thread := CG_Thread.new( self, sequence )
	thread.finished.connect( _thread_finished_reaction )
	
	if sequence.has_command( p_entrypoint_id ):
		thread.start( p_entrypoint_id )
	else:
		thread.start( sequence.entrypoint )
	
	return thread



func _thread_finished_reaction() -> void:
	
	_clear_finished_threads()
	
	if threads.is_empty():
		finished.emit()



func _clear_finished_threads() -> void:
	
	var finished_thread_indices := PackedInt32Array()
	
	for i in range( 0, threads.size(), 1 ):
		
		var thread := threads[i]
		
		if thread.current_command_state.is_finished():
			finished_thread_indices.push_back( i )
			thread.queue_free()
	
	
	for i in range( finished_thread_indices.size() - 1, -1, -1 ):
		threads.remove_at( i )
