extends Node2D

var num_wood : int = 0

func _on_wood_tree_gathered_wood():
	num_wood += 1
	print(num_wood)
