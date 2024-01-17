extends CharacterBody2D

# Constants
@export var SPEED = 70.0
var player = null
var mobile = false

# Variables
@export var max_health = 20
@onready var health = max_health

#func _ready():
	#player = get_parent().find_child("Player")
	##print(player)

func _physics_process(_delta):
	velocity = Vector2.ZERO
	if player:
		velocity = position.direction_to(player.position) * SPEED
		if mobile:
			move_and_slide()

func _on_vision_range_body_entered(body):
	if body.name == "Player":
		player = body
		mobile = true


func _on_vision_range_body_exited(body):
	if body.name == "Player":
		mobile = false
		player = null


func _on_attack_range_body_entered(body):
	mobile = false


func _on_attack_range_body_exited(body):
	mobile = true
