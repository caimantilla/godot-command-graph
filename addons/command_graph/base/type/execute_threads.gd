##############
# UNFINISHED #
##############


tool
extends "res://addons/command_graph/abstract/command.gd"


enum ThreadExecutionMode {
	SEQUENTIAL = 0,
	SIMULTANEOUS = 1,
}


## The next sequential command's ID.
export(String) var next_command_id = ""

## Tells whether to wait for each thread to finish before progressing to the next command.
export(bool) var wait_execution_finish_to_proceed = true

## The way to execute the threads started.
export(int, "Sequential", "Simultaneous") var thread_execution_mode = ThreadExecutionMode.SEQUENTIAL

## IDs of each thread to start.
export(StringArray) var thread_starter_ids = StringArray()


func execute(dependencies):
	var state = CommandState.new()
	
	if thread_execution_mode == ThreadExecutionMode.SIMULTANEOUS:
		pass
	
	
	if not wait_execution_finish_to_proceed:
		state.finish(next_command_id)
	
	return state


static func get_editor_id():
	return "execute_threads"

static func get_editor_name():
	return "Execute Threads"

static func get_editor_description():
	return "Starts new threads."
