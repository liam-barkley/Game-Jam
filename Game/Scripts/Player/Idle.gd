extends State

@onready var animated_sprite_2d = $"../../AnimatedSprite2D"

var direction = Vector2.ZERO

# Upon entering the state, we set the Player node's velocity to zero.
func enter(msg := {}) -> void:
	# We must declare all the properties we access through `owner` in the `Player.gd` script.
	owner.velocity = Vector2.ZERO
	
	if msg.has("direction"):
		direction = msg.direction

func update(delta: float) -> void:
	play_animation()
	
	if Input.is_action_just_pressed("attack"):
		# As we'll only have one air state for both jump and fall, we use the `msg` dictionary 
		# to tell the next state that we want to jump.
		state_machine.transition_to("Attack", {direction = direction})
	elif Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right") or Input.is_action_pressed("move_up") or Input.is_action_pressed("move_down"):
		state_machine.transition_to("Move")

func play_animation():
	if direction == Vector2.ZERO:
		animated_sprite_2d.play("idle_down")
		return
	
	match direction.y:
		-1.0:
			animated_sprite_2d.play("idle_up")
		1.0:
			animated_sprite_2d.play("idle_down")
	match direction.x:
		-1.0:
			animated_sprite_2d.play("idle_left")
		1.0:
			animated_sprite_2d.play("idle_right")
	
	if direction.x > 0.5 and direction.y < -0.5:
		animated_sprite_2d.play("idle_right_up")
	if direction.x > 0.5 and direction.y > 0.5:
		animated_sprite_2d.play("idle_right_down")
	if direction.x < -0.5 and direction.y < -0.5:
		animated_sprite_2d.play("idle_left_up")
	if direction.x < -0.5 and direction.y > 0.5:
		animated_sprite_2d.play("idle_left_down")
