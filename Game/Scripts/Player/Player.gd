extends CharacterBody2D

signal health_changed

# Nodes
@onready var state_machine = $StateMachine
@onready var camera_2d = $Camera2D

# Constants
@export var SPEED = 200.0
@export var FRICTION = 1600.0
@export var ACCELERATION = 800.0
@export var DAMAGE = 2

# Variables
@export var max_health = 20
@onready var health = max_health

func _physics_process(_delta):
	if health == 0:
		state_machine.transition_to("Death")

func _on_sword_hitbox_area_entered(area):
	if area.is_in_group("hurtbox"):
		area.take_damage(DAMAGE)

func _on_hurtbox_damage(amount):
	#$Eina.play()
	health = health - amount
	health_changed.emit()
	
func _input(event):
	if Input.is_action_just_pressed("zoom_in"):
		var zoom = camera_2d.zoom.x + 0.1
		camera_2d.zoom = Vector2(zoom, zoom)
	if Input.is_action_just_pressed("zoom_out"):
		var zoom = camera_2d.zoom.x - 0.1
		camera_2d.zoom = Vector2(zoom, zoom)
	
