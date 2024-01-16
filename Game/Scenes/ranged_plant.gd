extends Node2D

@onready var shoot_timer = $ShootTimer
@onready var ray_cast = $RayCast2D
@onready var bullety = get_parent().get_node("RangedPlantBullet")
@export var HEALTH = 10
@export var DAMAGE = 2
@export var ammo : PackedScene

var hurt_area
var player_in_proximity = false
var player
var shoot_allowed = false
var current_target

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_parent().find_child("Player")

#this function searches the closest tower to itself and returns that tower
func search_closest_tower():
	var closest_tower
	var closest_tower_dist = 100000000
	var towers = get_tree().get_nodes_in_group("Towers")
	if towers != null:
		for tower in towers:
			var dist = (tower.position.x-self.position.x)^2 + (tower.position.y - self.position.y)^2
			if (dist <= closest_tower_dist):
				closest_tower = tower
	return closest_tower
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	current_target = null
	if player_in_proximity == false:
		current_target = search_closest_tower()
	else:
		current_target = player
	
	if current_target != null:
		aim_at(current_target)
		check_target_collision(current_target)
	else:
		shoot_timer.stop()
	
func aim_at(target):
	
	if target!=null:
		ray_cast.target_position = target.position
		if target.name == "Player":
			var new_position = target.position
			new_position.x -= 14
			new_position.y -= 14
			ray_cast.target_position = to_local(new_position)
			
		
	
func check_target_collision(target):
	if (ray_cast.get_collider() == target or ray_cast.get_collider() == player) and shoot_timer.is_stopped():
		shoot_timer.start()
		
		
	elif !(ray_cast.get_collider() == target or ray_cast.get_collider() == player):
		#this can be inefficient
		shoot_timer.stop()
		shoot_allowed = false


	

# This is for when the player gets hurt
func _on_hurt_box_area_entered(area):
	if area.is_in_group("hurtbox"):
		hurt_area = area
		$HurtBox/Timer.start()
	


func _on_timer_timeout():
	hurt_area.take_damage(DAMAGE)


func _on_hurt_box_area_exited(area):
	if area.is_in_group("hurtbox"):
		hurt_area = null
		$HurtBox/Timer.stop()

func shoot(target):
	var bullet = ammo.instantiate()
	#bullet._set_owner("ENEMY")
	bullet.position = self.position
	bullet.direction = (ray_cast.target_position).normalized()
	get_tree().current_scene.add_child(bullet)

func _on_shoot_timer_timeout():
	shoot(current_target)


func _on_fire_range_body_entered(body):
	if body.name == "Player":
		player_in_proximity = true


func _on_fire_range_body_exited(body):
	if body.name == "Player":
		player_in_proximity = false
