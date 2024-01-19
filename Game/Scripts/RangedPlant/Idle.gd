extends State

@onready var animated_sprite_2d = $"../../AnimatedSprite2D"

var direction = Vector2.ZERO

# Upon entering the state, we set the Enemy node's velocity to zero.
func enter(msg := {}) -> void:
	# Direction to idle towards
	if msg.has("direction"):
		direction = msg.direction

func update(_delta: float) -> void:
	play_animation()

func play_animation():
	if direction == Vector2.ZERO:
		animated_sprite_2d.play("idle_down")
		return
	
	# Player is more below than beside
	if abs(direction.y) >= abs (direction.x):
		if direction.y >= 0:
			animated_sprite_2d.play("idle_down")
		else:
			animated_sprite_2d.play("idle_up")
		return

	if direction.x >= 0:
		animated_sprite_2d.play("idle_right")
	else:
		animated_sprite_2d.play("idle_left")
