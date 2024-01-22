extends Node2D

@onready var Ranged_enemy_state_machine = $RangedEnemyStateMachine
@onready var shoot_timer = $ShootTimer
@onready var ray_cast = $RayCast2D
@onready var bullety = get_parent().get_node("RangedPlantBullet")
@export var HEALTH = 10
@export var MAX_HEALTH = 10
@export var DAMAGE = 2
@export var ammo : PackedScene
@onready var playerRay = $playerRay
var hurt_area
var player_in_proximity = false
var player
var shoot_allowed = false
var current_target
var new_position 

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_parent().find_child("Player")
	

#this function searches the closest tower to itself and returns that tower
func search_closest_tower():
	var closest_tower
	var closest_tower_dist = 100000000
	var towers = get_tree().get_nodes_in_group("Towers")
	if towers.size() != 0:
		for tower in towers:
			var dist = (tower.position.x-self.position.x)*(tower.position.x-self.position.x)+ (tower.position.y - self.position.y)*(tower.position.y - self.position.y)
			if (dist <= closest_tower_dist):
				closest_tower = tower
	else:
		shoot_timer.stop()
	return closest_tower

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#print(self.position)
	current_target = null
	ray_cast.target_position = Vector2.ZERO
	if player_in_proximity == false:
		current_target = search_closest_tower()
	else:
		current_target = player
		
	#print(current_target)
	if current_target != null:
		aim_at(current_target)
		check_target_collision(current_target)
	else:
		var looky = position.direction_to(player.position)
		Ranged_enemy_state_machine.transition_to("Idle", {"direction" = looky})
		shoot_timer.stop()
	
func aim_at(target):
	
	if target!=null:
		ray_cast.target_position = target.position - self.position
	if player!=null:
		playerRay.target_position = player.position - self.position

func check_target_collision(target):
	
	
	if (target.is_in_group("Towers") or (ray_cast.get_collider() == player or playerRay.get_collider() == player)) and shoot_timer.is_stopped():
		shoot_timer.start()
		
		
	elif !(target.is_in_group("Towers") or (ray_cast.get_collider() == player or playerRay.get_collider() == player)):
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
	var looky = position.direction_to(target.position)
	Ranged_enemy_state_machine.transition_to("Attack", {"direction" = looky})
	var bullet = ammo.instantiate()
	#bullet._set_owner("ENEMY")
	if target.name == "Player":
		bullet.position = playerRay.global_position
		bullet.direction = (playerRay.target_position).normalized()
		get_tree().current_scene.add_child(bullet)
	else:
		bullet.position = ray_cast.global_position
		bullet.direction = (ray_cast.target_position).normalized()
		get_tree().current_scene.add_child(bullet)

func _on_shoot_timer_timeout():
	$plantshoot.play()
	shoot(current_target)

func _on_fire_range_body_entered(body):
	if body.name == "Player":
		player_in_proximity = true

func _on_fire_range_body_exited(body):
	if body.name == "Player":
		player_in_proximity = false
		var looky = position.direction_to(player.position)
		Ranged_enemy_state_machine.transition_to("Idle", {"direction" = looky})

func _on_damage_area_entered(area):
	print(area.is_in_group("Abullets"))
	if area.is_in_group("Weapons") or area.is_in_group("Abullets"):
		HEALTH -= 2
		if HEALTH <=0:
			#get_parent().num_enemies -= 1
			queue_free()
		
func _get_health():
	return HEALTH
