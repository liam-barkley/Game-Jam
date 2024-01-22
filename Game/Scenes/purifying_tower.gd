extends Node2D
@export var HEALTH = 10
const MAX_HEALTH = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	$HealthBar.value=100

func updateHealthbar():
	$HealthBar.value =HEALTH*100/MAX_HEALTH

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_2d_area_entered(area):
	if area.is_in_group("Ebullet"):
		HEALTH -= 2
		if HEALTH <= 0:
			queue_free()
