extends Node2D

var is_ready : bool = false
var is_player_nearby : bool = false

signal gathered_stone
# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_player_nearby:
		if Input.is_action_just_pressed("interact"):
			gathered_stone.emit()
			queue_free()

func _on_pickable_area_body_entered(body):
	if body.name == "Player":
		is_player_nearby = true

func _on_pickable_area_body_exited(body):
	if body.name == "Player":
		is_player_nearby = false
