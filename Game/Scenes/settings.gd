extends Node2D

@onready var mmAudio
# Called when the node enters the scene tree for the first time.
func _ready():
	mmAudio = get_parent().get_node("mmAudio")
	print(mmAudio)
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_h_slider_changed():
	print("meh")


func _on_back_pressed():
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")


func _on_h_slider_value_changed(value):
	print("meh")
