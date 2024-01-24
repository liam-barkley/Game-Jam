extends Node2D
@onready var Ranged_enemy_state_machine = $RangedEnemyStateMachine
@onready var shoot_timer = $ShootTimer
@onready var ray_cast = $RayCast2D
@export var ammo : PackedScene
@export var Health = 20

var shoot_allowed
var current_target
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	current_target = null

	
	current_target=search_for_enemies()
	#print(current_target)
	if current_target != null:
		aim_at(current_target)
		check_target_collision(current_target)
		
	
func search_for_enemies():
	var closest_enemy
	var closest_enemy_dist = 100000000
	var enemies = get_tree().get_nodes_in_group("Enemies")
	
	if enemies.size() != 0:
		
		for enemy in enemies:
			
			var dist = (enemy.position.x-self.position.x)*(enemy.position.x-self.position.x) + (enemy.position.y - self.position.y)*(enemy.position.y - self.position.y)
			if (dist <= closest_enemy_dist) and enemy.name != "HurtBox":
				closest_enemy_dist = dist
				closest_enemy = enemy
	else:
		shoot_timer.stop()
	return closest_enemy

func aim_at(target):
	
	if target!=null:
		ray_cast.target_position = to_local(target.global_position)
		

func check_target_collision(target):
	
		
	if  (target.is_in_group("Enemies") ) and shoot_timer.is_stopped():
		shoot_timer.start()
		
		
	elif !(target.is_in_group("Enemies")):
		#this can be inefficient
		shoot_timer.stop()
		shoot_allowed = false

func shoot(target):
	var bullet = ammo.instantiate()
	#bullet._set_owner("ENEMY")
	bullet.position = ray_cast.global_position
	bullet.direction = (ray_cast.target_position).normalized()
	get_tree().current_scene.add_child(bullet)



func _on_hurtbox_area_entered(area):
	if area.is_in_group("Ebullet"):
		
		Health-= 2
		print(Health)
		if Health <= 0:
			queue_free()


func _on_shoot_timer_timeout():
	shoot(current_target)


func _on_hurtbox_damage(amount):
	Health = Health - amount
	if Health <= 0:
			queue_free()
