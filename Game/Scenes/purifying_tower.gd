extends Node2D
@export var HEALTH = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_2d_area_entered(area):
	if area.is_in_group("Ebullet"):
		print("hello")
		HEALTH -= 2
		if HEALTH <= 0:
			queue_free()
