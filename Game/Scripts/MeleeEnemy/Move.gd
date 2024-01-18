extends State

@onready var animated_sprite_2d = $"../../AnimatedSprite2D"

var old_direction = Vector2.ZERO
var direction = Vector2.ZERO
var player = null
var standing = false

func enter(msg := {}) -> void:
	if msg.has("player"):
		player = msg.player

	standing = false
	play_stand_animation()
	await animated_sprite_2d.animation_finished
	standing = true

func physics_update(delta: float) -> void:
	if standing:
		direction = owner.global_transform.origin.direction_to(player.global_transform.origin)
		play_walk_animation()
		owner.velocity = direction * owner.SPEED
		owner.move_and_slide()

func play_stand_animation():
	# Player more below than beside
	if abs(direction.y) >= abs(direction.x):
		if direction.y >= 0:
			animated_sprite_2d.play("stand_down")
		else:
			animated_sprite_2d.play("stand_up")
		return

	if direction.x >= 0:
		animated_sprite_2d.play("stand_right")
	else:
		animated_sprite_2d.play("stand_left")

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
