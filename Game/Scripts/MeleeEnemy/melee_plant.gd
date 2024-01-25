extends CharacterBody2D

@onready var melee_enemy_state_machine = $MeleeEnemyStateMachine
@onready var animated_sprite_2d = $AnimatedSprite2D

# Constants
@export var SPEED = 50.0
@export var DAMAGE = 4
@export var HEALTH = 10
@export var MAX_HEALTH = 10

# Variables
var hurt_area
var target = null
var direction = Vector2.ZERO
var mobile = true
var dead = false

func _physics_process(_delta):
	if not dead:
		updateHealthbar()
		_find_closest_target()
		
		if target && !_is_closer_enemy_available() && mobile:
			direction = global_transform.origin.direction_to(target.global_transform.origin)
			play_walk_animation()
			velocity = direction * SPEED
			move_and_slide()

func play_walk_animation():
	# Player more below than beside
	if abs(direction.y) >= abs (direction.x):
		if direction.y >= 0:
			animated_sprite_2d.play("move_down")
		else:
			animated_sprite_2d.play("move_up")
		return

	if direction.x >= 0:
		animated_sprite_2d.play("move_right")
	else:
		animated_sprite_2d.play("move_left")

func _on_vision_range_body_entered(body):
	if dead: return
	if body.name == "Player" || body.is_in_group("Towers"):
		_find_closest_target()
		#print("Body entered: ", body)
		if target != null:
			melee_enemy_state_machine.transition_to("Move", {"player" = target})

func _on_vision_range_body_exited(body):
	if dead: return
	if body.name == "Player" || body.is_in_group("Towers"):
		_find_closest_target()
		if target == null:
			var direction = position.direction_to(body.position)
			melee_enemy_state_machine.transition_to("Idle", {"direction" = direction})

func _on_attack_range_body_entered(body):
	if dead: return
	if !body.is_in_group("AllyBody"):
		return
	
	if target != null:
		mobile = false
		#print("Attacking target: ", target)
		melee_enemy_state_machine.transition_to("Attack", {"player" = target})
		#await get_tree().create_timer(0.75).timeout
		$WaitTimer.start()
		await $WaitTimer.timeout
		if hurt_area != null:
			hurt_area.take_damage(DAMAGE)

func _on_attack_range_body_exited(body):
	if dead: return
	if !body.is_in_group("AllyBody"):
		return

	if target != null:
		mobile = true
		melee_enemy_state_machine.transition_to("Move", {"player" = target})

func _on_attack_range_area_entered(area):
	if dead: return
	if area.is_in_group("hurtbox"):
		hurt_area = area

func _on_attack_range_area_exited(area):
	if dead: return
	if area.is_in_group("hurtbox"):
		hurt_area = null

func _on_attack_timer_timeout():
	if dead: return
	# give time to get away
	await get_tree().create_timer(0.75).timeout
	#print("##########################################################")
	#print("Hurt area: ", hurt_area)
	#print("##########################################################")
	if hurt_area != null:
		hurt_area.take_damage(DAMAGE)

func _on_hurtbox_area_entered(area):
	if dead: return
	if area.is_in_group("Weapons") :
		HEALTH -= 2

	if area.is_in_group("Abullets"):
		HEALTH -= 1

	if HEALTH <=0:
		get_parent().num_enemies -= 1
		melee_enemy_state_machine.transition_to("Death")
		dead = true

func _find_closest_target():
	var closest_enemy = null
	var shortest_distance = 100000000000
	for body in $VisionRange.get_overlapping_bodies():
		if body is CharacterBody2D || body is StaticBody2D && !body.is_in_group("Enemies"):
			var body_position = body.global_position
			var distance = global_position.distance_to(body_position)
			if distance < shortest_distance:
				shortest_distance = distance
				closest_enemy = body
	if closest_enemy:
		target = closest_enemy
		#print("--------------------------------")
		#print("Closest enemy found: ", target.name)
		#print("--------------------------------")
	else:
		target = null

func _is_closer_enemy_available():
	for body in $VisionRange.get_overlapping_bodies():
		if body is CharacterBody2D || body is StaticBody2D && !body.is_in_group("Enemies"):
			if global_position.distance_to(body.global_position) < global_position.distance_to(target.global_position):
				return true
	return false

func updateHealthbar():
	$healthbar.value =HEALTH*100/MAX_HEALTH
