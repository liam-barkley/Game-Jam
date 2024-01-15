extends CharacterBody2D

# Constants
@export var SPEED = 70.0
var player = null

# Variables
@export var max_health = 20
@onready var health = max_health


func _physics_process(_delta):
	velocity = Vector2.ZERO
	if player:
		velocity = position.direction_to(player.position) * SPEED
		if position.distance_to(player.position) > 30:
			move_and_slide()

func _on_vision_range_body_entered(body):
	if body.name == "Player":
		player = body


func _on_vision_range_body_exited(body):
	if body.name == "Player":
		player = null
