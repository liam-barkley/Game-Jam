extends State

@onready var animated_sprite_2d = $"../../AnimatedSprite2D"
@onready var attack_timer = $"../../AttackTimer"

var direction = Vector2.ZERO
var player = null

func enter(msg := {}) -> void:
	if msg.has("direction"):
		direction = msg.direction

func update(_delta: float) -> void:
	play_animation()
	
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
