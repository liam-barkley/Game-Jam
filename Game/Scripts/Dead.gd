extends State

@onready var animated_sprite_2d = $"../../AnimatedSprite2D"
@onready var ranged_plant = $"../../.."

func physics_update(delta: float) -> void:
	animated_sprite_2d.play("death")
	await animated_sprite_2d.animation_finished
	ranged_plant.queue_free()
