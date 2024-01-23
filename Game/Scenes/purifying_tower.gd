extends Node2D
@export var HEALTH = 25
const MAX_HEALTH = 25
@onready var collision_shape_2d = $Area2D/CollisionShape2D
@onready var sprite_2d = $Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	$HealthBar.value=100

func updateHealthbar():
	$HealthBar.value =HEALTH*100/MAX_HEALTH

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

	

func _on_timer_timeout():
	collision_shape_2d.scale += Vector2(0.1, 0.1)
	sprite_2d.scale += Vector2(0.05, 0.05)
	
	if collision_shape_2d.scale > Vector2(1.1, 1.1):
		$Timer.queue_free()


func _on_hit_box_area_entered(area):
	if area.is_in_group("Ebullet"):
		
		HEALTH -= 2
		updateHealthbar()
		if HEALTH <= 0:
			queue_free()
