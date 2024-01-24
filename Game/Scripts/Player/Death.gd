extends State

@onready var animated_sprite_2d = $"../../AnimatedSprite2D"

func enter(_msg := {}) -> void:
	owner.velocity = Vector2.ZERO
	
	animated_sprite_2d.play("death")
	await animated_sprite_2d.animation_finished
	get_tree().paused = true
