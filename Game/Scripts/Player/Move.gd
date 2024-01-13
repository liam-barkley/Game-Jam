extends State

@onready var animated_sprite_2d = $"../../AnimatedSprite2D"

func update(delta: float) -> void:
	# We move the run-specific input code to the state.
	# A good alternative would be to define a `get_input_direction()` function on the `Player.gd`
	# script to avoid duplicating these lines in every script.
	# Get the input direction and handle states
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	apply_acceleration(direction, delta)
	apply_friction(direction, delta)
	play_animation(direction)
	owner.move_and_slide()

	if Input.is_action_just_pressed("attack"):
		state_machine.transition_to("Attack", {direction = direction})
	elif owner.velocity == Vector2.ZERO:
		state_machine.transition_to("Idle")

func apply_acceleration(direction, delta):
	if not direction == Vector2.ZERO:
		owner.velocity.x = move_toward(owner.velocity.x, direction.x * owner.SPEED, owner.ACCELERATION * delta)
		owner.velocity.y = move_toward(owner.velocity.y, direction.y * owner.SPEED, owner.ACCELERATION * delta)

func apply_friction(direction, delta):
	if direction == Vector2.ZERO:
		owner.velocity.x = move_toward(owner.velocity.x, 0, owner.FRICTION * delta)
		owner.velocity.y = move_toward(owner.velocity.y, 0, owner.FRICTION * delta)

func play_animation(direction):
	match direction.y:
		-1.0:
			animated_sprite_2d.play("up")
		1.0:
			animated_sprite_2d.play("down")
	match direction.x:
		-1.0:
			animated_sprite_2d.play("left")
		1.0:
			animated_sprite_2d.play("right")
	
	if direction.x > 0.5 and direction.y < -0.5:
		animated_sprite_2d.play("right_up")
	if direction.x > 0.5 and direction.y > 0.5:
		animated_sprite_2d.play("right_down")
	if direction.x < -0.5 and direction.y < -0.5:
		animated_sprite_2d.play("left_up")
	if direction.x < -0.5 and direction.y > 0.5:
		animated_sprite_2d.play("left_down")
