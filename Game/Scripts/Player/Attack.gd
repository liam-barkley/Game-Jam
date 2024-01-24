extends State

@onready var animated_sprite_2d = $"../../AnimatedSprite2D"
@onready var sword_hitbox = $"../../SwordHitbox"
@onready var collision_shape_2d = $"../../SwordHitbox/CollisionShape2D"

var direction = Vector2.ZERO

func enter(msg := {}) -> void:
	if msg.has("direction"):
		direction = msg.direction
	
	play_animation()
	$"../../AttackSound".play()
	adjust_hitbox()
	collision_shape_2d.disabled = false
	await animated_sprite_2d.animation_finished
	collision_shape_2d.disabled = true
	
	state_machine.transition_to("Idle", {direction = direction})

func update(_delta: float) -> void:
	pass

func play_animation():
	if direction == Vector2.ZERO:
		animated_sprite_2d.play("attack_down")
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
