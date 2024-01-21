extends Node2D

#@onready var healer_enemy_state_machine = $HealerEnemyStateMachine

#Constants
@export var HEAL = 1

#Variables
var target
var can_heal_enemy = false
var waiting_for_process = false
@onready var heal_timer = $HealTimer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if waiting_for_process:
		return
	if target == null:
		_find_new_target()
		print("New target found: ", target)
	
		waiting_for_process = true
		$WaitTimer.start()
		
	if target != null:
		waiting_for_process = true
		$WaitTimer.start()
		if target.name == "MeleePlant":
			if $HealRange.overlaps_body(target) && can_heal_enemy:
				heal_timer.start()
				can_heal_enemy = false
				print("Timer started")
		if target.name == "RangedPlant":
			if $HealRange.overlaps_body(target.get_parent()) && can_heal_enemy:
				heal_timer.start()
				can_heal_enemy = false

func _on_vision_range_body_entered(body):
	if target == null:
		print("Target entered vision range")
		_find_new_target()

func _on_vision_range_body_exited(body):
	if _same_target(body):
		print("Target exited vision range")
		target = null
		_find_new_target()

func _on_heal_range_body_entered(body):
	if _same_target(body):
		print("Target entered healing range")
		heal_timer.start()

func _on_heal_range_body_exited(body):
	if _same_target(body):
		print("Target exited healing range")
		heal_timer.stop()

func _on_heal_timer_timeout():
	print("Timer timeout")
	if target != null:
		print("------------------------------------------")
		print("Target to heal: ", target)
		print("Target health: ", target.HEALTH)
		print("------------------------------------------")
		_heal_current_target(target)

func _heal_current_target(heal_target):
	if heal_target.HEALTH < heal_target.MAX_HEALTH:
		heal_target.HEALTH += HEAL
	else:
		target = null
		heal_timer.stop()

func _find_new_target():
	for body in $VisionRange.get_overlapping_bodies():
		if body is CharacterBody2D && body.name != "HealerPlant":
			if body.name == "RangedPlant":
				if body.get_parent().HEALTH < body.get_parent().MAX_HEALTH:
					target = body.get_parent()
					can_heal_enemy = true
			if body.name == "MeleePlant":
				if body.HEALTH < body.MAX_HEALTH:
					target = body
					can_heal_enemy = true

func _same_target(body):
	if body.name == "RangedPlant":
		if body.get_parent() == target:
			return true
	if body.name == "MeleePlant":
		if body == target:
			return true


func _on_wait_timer_timeout():
	waiting_for_process = false
