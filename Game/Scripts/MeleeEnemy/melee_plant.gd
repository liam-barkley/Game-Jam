extends CharacterBody2D

@onready var melee_enemy_state_machine = $MeleeEnemyStateMachine

# Constants
@export var SPEED = 70.0

# Variables
@export var max_health = 20
@onready var health = max_health

func _physics_process(_delta):
	pass

func _on_vision_range_body_entered(body):
	if body.name == "Player":
		#player = body
		#mobile = true
		melee_enemy_state_machine.transition_to("Move", {"player" = body})

func _on_vision_range_body_exited(body):
	if body.name == "Player":
		#mobile = false
		#player = null
		var direction = position.direction_to(body.position)
		melee_enemy_state_machine.transition_to("Idle", {"direction" = direction})

func _on_attack_range_body_entered(body):
	if body.name != "Player":
		return
		
	melee_enemy_state_machine.transition_to("Attack", {"player" = body})

func _on_attack_range_body_exited(body):
	if body.name != "Player":
		return

	var direction = position.direction_to(body.position)
	melee_enemy_state_machine.transition_to("Move", {"player" = body})
