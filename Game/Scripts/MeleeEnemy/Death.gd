extends State

@onready var animated_sprite_2d = $"../../AnimatedSprite2D"
@onready var melee_plant = $"../.."

func enter(_msg := {}) -> void:
	animated_sprite_2d.play("death")
	await animated_sprite_2d.animation_finished
	melee_plant.queue_free()
