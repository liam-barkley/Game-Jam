extends State

@onready var animated_sprite_2d = $"../../AnimatedSprite2D"
@onready var sword_hitbox = $"../../SwordHitbox"

var old_direction = Vector2.ZERO
var direction = Vector2.ZERO

func enter(msg := {}) -> void:
	print("Player Entering Move state")

func physics_update(delta: float) -> void:
	# Get the input direction and handle states
	if direction != Vector2.ZERO:
		# Here we remember the old direction on order to transition to correct idle state
		old_direction = direction
	direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	apply_acceleration(delta)
	apply_friction(delta)
	play_animation()
	owner.move_and_slide()

	if Input.is_action_just_pressed("attack"):
		state_machine.transition_to("Attack", {direction = direction})
	elif direction.is_zero_approx():
		state_machine.transition_to("Idle", {direction = old_direction})

func apply_acceleration(delta):
	if not direction == Vector2.ZERO:
		if Input.is_action_pressed("sprint"):
			owner.velocity.x = move_toward(owner.velocity.x, direction.x * (owner.SPEED*1.5), owner.ACCELERATION * delta)
			owner.velocity.y = move_toward(owner.velocity.y, direction.y * (owner.SPEED*1.5), owner.ACCELERATION * delta)
		else:
			owner.velocity.x = move_toward(owner.velocity.x, direction.x * owner.SPEED, owner.ACCELERATION * delta)
			owner.velocity.y = move_toward(owner.velocity.y, direction.y * owner.SPEED, owner.ACCELERATION * delta)

func apply_friction(delta):
	if direction == Vector2.ZERO:
		owner.velocity.x = move_toward(owner.velocity.x, 0, owner.FRICTION * delta)
		owner.velocity.y = move_toward(owner.velocity.y, 0, owner.FRICTION * delta)

func play_animation():
	# Player more below than beside
	if abs(direction.y) >= abs (direction.x):
		if direction.y >= 0:
			animated_sprite_2d.play("down")
		else:
			animated_sprite_2d.play("up")
		return

	if direction.x >= 0:
		animated_sprite_2d.play("right")
	else:
		animated_sprite_2d.play("left")
	
	#if direction.x > 0.5 and direction.y < -0.5:
		#animated_sprite_2d.play("right_up")
	#if direction.x > 0.5 and direction.y > 0.5:
		#animated_sprite_2d.play("right_down")
	#if direction.x < -0.5 and direction.y < -0.5:
		#animated_sprite_2d.play("left_up")
	#if direction.x < -0.5 and direction.y > 0.5:
		#animated_sprite_2d.play("left_down")
