extends CharacterBody2D

@onready var melee_enemy_state_machine = $MeleeEnemyStateMachine

# Constants
@export var SPEED = 70.0
@export var DAMAGE = 1
@export var HEALTH = 6
@export var MAX_HEALTH = 6

# Variables
var hurt_area

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

func _on_attack_range_area_entered(area):
	if area.is_in_group("hurtbox"):
		hurt_area = area

func _on_attack_range_area_exited(area):
	if area.is_in_group("hurtbox"):
		hurt_area = null

func _on_attack_timer_timeout():
	# give time to get away
	await get_tree().create_timer(0.75).timeout
	if hurt_area != null:
		hurt_area.take_damage(DAMAGE)

func _on_hurtbox_area_entered(area):
	if area.is_in_group("Weapons") :
		HEALTH -= 2
		
		
	if area.is_in_group("Abullets"):
		HEALTH -= 1
	if HEALTH <=0:
			#get_parent().num_enemies -= 1
			queue_free()
