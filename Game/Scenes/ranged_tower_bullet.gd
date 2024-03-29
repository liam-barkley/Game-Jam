extends Node2D

var direction : Vector2 = Vector2.RIGHT
var speed : float = 250
var DAMAGE = 2
var attack_pressed=false
var area_space
var oldpos = Vector2.ZERO
@onready var Health =2
# Called when the  node enters the scene tree for the first time.
func _ready():
	pass

func _process(delta):
	if oldpos != self.global_position:
		oldpos = self.global_position
	else:
		queue_free()
	attack_pressed = Input.is_action_just_pressed("attack")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	position +=direction * speed * delta

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()


func _on_bullet_size_body_entered(body):
	pass


func _on_bullet_size_area_exited(area):
	area_space = null


func _on_area_2d_area_entered(area):
	area_space=area
	if area.is_in_group("Weapons"):
		queue_free()
	if area.is_in_group("Enemies"):
		queue_free()
	if area.is_in_group("EnemyHealth"):
		queue_free()
	# Check if bullet is in player attack area
	if area.is_in_group("hurtbox"):
		queue_free()


func _on_timer_timeout():
	queue_free()
