extends State

@onready var animated_sprite_2d = $"../../AnimatedSprite2D"
@onready var sword_hitbox = $"../../SwordHitbox"
@onready var collision_shape_2d = $"../../SwordHitbox/CollisionShape2D"

var direction = Vector2.ZERO

func enter(msg := {}) -> void:
	if msg.has("direction"):
		direction = msg.direction

func update(_delta: float) -> void:
	play_animation()
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
		animated_sprite_2d.play("attack_down")
	
	match direction.y:
		-1.0:
			animated_sprite_2d.play("attack_up")
		1.0:
			animated_sprite_2d.play("attack_down")
	match direction.x:
		-1.0:
			animated_sprite_2d.play("attack_left")
		1.0:
			animated_sprite_2d.play("attack_right")
	
	if direction.x > 0.5 and direction.y < -0.5:
		animated_sprite_2d.play("attack_right_up")
	if direction.x > 0.5 and direction.y > 0.5:
		animated_sprite_2d.play("attack_right_down")
	if direction.x < -0.5 and direction.y < -0.5:
		animated_sprite_2d.play("attack_left_up")
	if direction.x < -0.5 and direction.y > 0.5:
		animated_sprite_2d.play("attack_left_down")

func adjust_hitbox():
	var offset = Vector2(2, 0)
	var rotation = direction.angle()
	
	sword_hitbox.global_position = owner.global_position + offset.rotated(rotation)
	sword_hitbox.rotation = rotation
