extends Node2D

var direction : Vector2 = Vector2.RIGHT
var speed : float = 300
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	position +=direction * speed * delta




func _on_bullet_size_area_entered(area):
	# Check if bullet is in player attack area
	if area.is_in_group("Weapons"):
		
		# If player clicked attack it will kill the bullet
		if Input.is_action_just_pressed("attack"):
			print("Im Free")
			self.free()
		


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()


func _on_bullet_size_body_entered(body):
	print("Owch")
