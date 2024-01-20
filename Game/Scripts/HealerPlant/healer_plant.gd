extends Node2D

#@onready var healer_enemy_state_machine = $HealerEnemyStateMachine


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_vision_range_body_entered(body):
	if body is CharacterBody2D:
		if body.is_in_group("Enemies"):
			if body.name != "HealerPlant":
				print("In vision range")
				print(body.name)
