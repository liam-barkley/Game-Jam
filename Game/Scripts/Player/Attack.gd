extends State

@onready var animated_sprite_2d = $"../../AnimatedSprite2D"
@onready var sword_hitbox = $"../../SwordHitbox"
@onready var collision_shape_2d = $"../../SwordHitbox/CollisionShape2D"


var direction = Vector2.ZERO

func enter(msg := {}) -> void:
	# print("Player entering ATTACK state")
	if msg.has("direction"):
		direction = msg.direction

func update(_delta: float) -> void:
	
	
	play_animation()
	$"../../AttackSound".play()
	adjust_hitbox()
	collision_shape_2d.disabled = false
	await animated_sprite_2d.animation_finished
	collision_shape_2d.disabled = true
	
	if Input.is_action_just_pressed("attack"):
		
		# As we'll only have one air state for both jump and fall, we use the `msg` dictionary 
		# to tell the next state that we want to jump.
		state_machine.transition_to("Attack")
	elif Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right") or Input.is_action_pressed("move_up") or Input.is_action_pressed("move_down"):
		state_machine.transition_to("Move")
	else:
		state_machine.transition_to("Idle", {direction = direction})

func play_animation():
	if direction == Vector2.ZERO:
		animated_sprite_2d.play("idle_down")
		return
	
	if abs(direction.y) >= abs(direction.x):
		if direction.y >= 0:
			animated_sprite_2d.play("attack_down")
		else:
			animated_sprite_2d.play("attack_up")
		return

	if direction.x >= 0:
		animated_sprite_2d.play("attack_right")
	else:
		animated_sprite_2d.play("attack_left")
	
	#if direction.x > 0.5 and direction.y < -0.5:
		#animated_sprite_2d.play("attack_right_up")
	#if direction.x > 0.5 and direction.y > 0.5:
		#animated_sprite_2d.play("attack_right_down")
	#if direction.x < -0.5 and direction.y < -0.5:
		#animated_sprite_2d.play("attack_left_up")
	#if direction.x < -0.5 and direction.y > 0.5:
		#animated_sprite_2d.play("attack_left_down")

func adjust_hitbox():
	var offset = Vector2(2, 0)
	var rotation = direction.angle()

	# Determine the predominant direction
	if abs(direction.x) <= abs(direction.y):
		# Vertical movement is more significant, prioritize up or down
		if direction.y < 0:
			rotation = deg_to_rad(270)  # Rotate downwards
		else:
			rotation = deg_to_rad(90)  # Rotate upwards
	else:
		# Horizontal movement is more significant, use the original rotation
		rotation = deg_to_rad(round(rad_to_deg(rotation) / 90.0) * 90.0)

	sword_hitbox.global_position = owner.global_position + offset.rotated(rotation)
	sword_hitbox.rotation = rotation
