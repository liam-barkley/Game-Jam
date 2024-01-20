extends Node2D

#@onready var healer_enemy_state_machine = $HealerEnemyStateMachine
#Constants
@export var HEAL = 1

#Variables
var target
@onready var heal_timer = $HealTimer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_vision_range_body_entered(body):
	if body is CharacterBody2D:
		if body.is_in_group("Enemies"):
			if body.name == "RangedPlant":
				print("Ranged in vision range")
				print(body.get_parent().HEALTH)
			if body.name == "MeleePlant":
				print("Melee in vision range")
				print(body.HEALTH)

func _on_heal_range_body_entered(body):
	if body.is_in_group("Enemies"):
		heal_timer.start()
		if body.name == "RangedPlant":
			target = body.get_parent()
		if body.name == "MeleePlant":
			target = body

func _on_heal_range_body_exited(body):
	heal_timer.stop()

func _on_heal_timer_timeout():
	_heal_current_target(target)

func _heal_current_target(heal_target):
	print("Health of target: ", heal_target.HEALTH)
	if heal_target.HEALTH < heal_target.MAX_HEALTH:
		heal_target.HEALTH += HEAL
