extends Node2D

@export var HEAL_AMOUNT = 1
var HEALTH = 15
@onready var timer = $Timer

var player

func updateHealthbar():
	$HealthBar.value =HEALTH*100/15

func _on_area_2d_body_entered(body):
	if body.name == "Player":
		player = body
		timer.start()

func _on_area_2d_body_exited(body):
	if body.name == "Player":
		player = null
		timer.stop()


func _on_timer_timeout():
	if player != null:
		print("healing player!")
		player._heal_player(HEAL_AMOUNT)

func _on_hit_box_area_entered(area):
	if area.is_in_group("Ebullet"):
		HEALTH -= 2
		updateHealthbar()
		if HEALTH <= 0:
			queue_free()

func _on_hit_box_damage(amount):
	
	HEALTH = HEALTH - amount
	updateHealthbar()
	if HEALTH <= 0:
			queue_free()


func _on_ready():
	$HealthBar.value=100
