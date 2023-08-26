@tool
class_name CommandDependencies
extends Node


var tree: SceneTree = null


func _enter_tree() -> void:
	tree = get_tree()


func _exit_tree() -> void:
	tree = null
