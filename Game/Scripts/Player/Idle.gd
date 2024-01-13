extends State

@onready var animated_sprite_2d = $"../../AnimatedSprite2D"


# Upon entering the state, we set the Player node's velocity to zero.
func enter(_msg := {}) -> void:
	# We must declare all the properties we access through `owner` in the `Player.gd` script.
	owner.velocity = Vector2.ZERO

func update(delta: float) -> void:
	animated_sprite_2d.play("idle")
	
	if Input.is_action_just_pressed("attack"):
		# As we'll only have one air state for both jump and fall, we use the `msg` dictionary 
		# to tell the next state that we want to jump.
		state_machine.transition_to("Attack", {direction = Vector2.ZERO})
	elif Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right") or Input.is_action_pressed("move_up") or Input.is_action_pressed("move_down"):
		state_machine.transition_to("Move")
