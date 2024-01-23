extends Node2D

var direction : Vector2 = Vector2.RIGHT
var speed : float = 100
var DAMAGE = 2
var attack_pressed=false
var area_space
@onready var animated_sprite_2d = $BulletSize/AnimatedSprite2D
@onready var Health =2
# Called when the  node enters the scene tree for the first time.
func _ready():
	pass

func _process(delta):
	attack_pressed = Input.is_action_just_pressed("attack")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	position +=direction * speed * delta

func _on_bullet_size_area_entered(area):
	area_space=area
	print(area.name + str(area.is_in_group("Allies")))
	if area.is_in_group("Weapons"):
		queue_free()
	if area.is_in_group("Allies"):
		queue_free()
	# Check if bullet is in player attack area
	if area.is_in_group("hurtbox"):
		area.take_damage(DAMAGE)
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()


func _on_bullet_size_body_entered(body):
	pass


func _on_bullet_size_area_exited(area):
	area_space = null
