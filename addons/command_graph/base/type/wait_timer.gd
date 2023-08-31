tool
extends "res://addons/command_graph/abstract/command.gd"


export(String) var next_command_id = "" setget set_next_command_id, get_next_command_id
export(float, 0.01, 999.9) var seconds = 1.0 setget set_seconds, get_seconds
#export(bool) var ignore_time_scale = false


static func get_editor_id():
	return "wait_timer"

static func get_editor_name():
	return "Wait Timer"

static func get_editor_description():
	return "Waits a specific length of time before proceeding."

static func get_editor_scene_path():
	return "res://addons/command_graph/base/node/wait_timer.tscn"



func set_next_command_id(value):
	next_command_id = value

func get_next_command_id():
	return next_command_id

func set_seconds(value):
	seconds = value

func get_seconds():
	return seconds



func update_command_references(from, to):
	if from == next_command_id:
		next_command_id = to


func execute(dependencies):
	var state = CommandState.new()
	
	if dependencies.tree == null or is_zero_approx(seconds) or seconds < 0.0:
		state.finish(next_command_id)
	else:
		var timer = Timer.new()
		dependencies.event.add_child(timer)
		timer.connect("timeout", self, "_on_timeout", [dependencies, state, timer], CONNECT_ONESHOT)
		timer.start()
	
	return state


func _on_timeout(dependencies, state, timer):
	timer.queue_free()
	state.finish(next_command_id)
