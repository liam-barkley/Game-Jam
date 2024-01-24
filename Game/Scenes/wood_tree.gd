extends Node2D

var is_ready : bool = false
var is_player_nearby : bool = false
@onready var texture_rect = $TextureRect

signal gathered_wood
# Called when the node enters the scene tree for the first time.
func _ready():
	start_timer()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not is_ready:
		$AnimatedSprite2D.play("stub")
	else:
		$AnimatedSprite2D.play("tree")
		if is_player_nearby:
			if Input.is_action_just_pressed("interact"):
				is_ready = false
				gathered_wood.emit()
				start_timer()
	
	texture_rect.visible = is_player_nearby and is_ready

func start_timer():
	var r = randi() % 15 + 5
	$GrowthTimer.wait_time = r
	$GrowthTimer.start()
	
func _on_growth_timer_timeout():
	if is_ready == false:
		is_ready = true

func _on_pickable_area_body_entered(body):
	if body.name == "Player":
		is_player_nearby = true

func _on_pickable_area_body_exited(body):
	if body.name == "Player":
		is_player_nearby = false
