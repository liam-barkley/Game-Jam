extends CharacterBody2D

# Nodes
@onready var state_machine = $StateMachine

# Constants
@export var SPEED = 200.0
@export var FRICTION = 1600.0
@export var ACCELERATION = 800.0

# Variables
@export var health = 20

func _physics_process(_delta):
	if health == 0:
		state_machine.transition_to("Death")
