extends CharacterBody2D

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
var TowerInArea = false
const SPEED = 30
var direction = Vector2.ZERO
# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_parent().get_parent().find_child("Player")
	
	if player == null:
		player = get_parent().find_child("Player")
	
	

#this function searches the closest tower to itself and returns that tower
func search_closest_tower():
	var closest_tower
	var closest_tower_dist = 100000000
	var towers = get_tree().get_nodes_in_group("Towers")
	if towers.size() != 0:
		for tower in towers:
			var dist = (tower.position.x-self.position.x)*(tower.position.x-self.position.x)+(tower.position.y - self.position.y)*(tower.position.y - self.position.y)
			
			if (dist < closest_tower_dist):
				closest_tower_dist = dist
				closest_tower = tower
	else:
		return null
	return closest_tower
	
func updateHealthbar():
	$healthbar.value =HEALTH*100/MAX_HEALTH

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	updateHealthbar()
	if player != null:
		playerRay.target_position = to_local(player.global_position)
	current_target = null
	if velocity != Vector2.ZERO:
		print(velocity)
		shoot_timer.stop()
	ray_cast.target_position = Vector2.ZERO
	if player_in_proximity == false:
		current_target = search_closest_tower()
	else:
		current_target = player
	
	
	
	if current_target != null:
		aim_at(current_target)
		velocity = global_position.direction_to(current_target.global_position) * SPEED
		if TowerInArea or player_in_proximity:
			velocity = Vector2.ZERO
			
			check_target_collision(current_target)
			
		
	else:
		var looky = position.direction_to(player.global_position)
		Ranged_enemy_state_machine.transition_to("Idle", {"direction" = looky})
		shoot_timer.stop()
	move_and_slide()
	
func aim_at(target):
	
	if target!=null:
		ray_cast.target_position = to_local(target.global_position)
	ray_cast.force_raycast_update()
	playerRay.force_raycast_update()

func check_target_collision(target):
	
	#print(str((ray_cast.get_collider() == player or playerRay.get_collider() == player))+" "+target.name)
	#print(str(ray_cast.get_collider())+" "+ str(playerRay.get_collider())+" "+target.name)
	if (target.is_in_group("Towers") or (ray_cast.get_collider() == player or playerRay.get_collider() == player)) and shoot_timer.is_stopped() and velocity == Vector2.ZERO:
		shoot_timer.start()
		print("shoot")
		
		
	elif !(target.is_in_group("Towers") or !(ray_cast.get_collider() == player or playerRay.get_collider() == player)) and shoot_timer.is_stopped():
		#this can be inefficient
		print("stop shoot")
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
	bullet.rotation = looky.angle() + 1.5708
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
	if area.is_in_group("Weapons") or area.is_in_group("Abullets"):
		HEALTH -= 2
		if HEALTH <=0:
			get_parent().get_parent().num_enemies -= 1
			get_parent().queue_free()
		
func _get_health():
	return HEALTH


func _on_tower_shoot_area_entered(area):
	print(area.name+""+str(area))
	if area.is_in_group("Allies"):
		TowerInArea = true


func _on_tower_shoot_area_exited(area):
	if area.is_in_group("Allies"):
		print(false)
		TowerInArea = false
