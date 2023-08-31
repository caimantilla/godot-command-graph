tool
extends Node


var tree = null


func _enter_tree():
	tree = get_tree()


func _exit_tree():
	tree = null
