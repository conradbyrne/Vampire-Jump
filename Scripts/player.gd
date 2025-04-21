extends CharacterBody2D
@export var jump_force = 800.0
@export var gravity = 1200.0
@export var move_speed = 200.0

func _physics_process(delta):
	# Horizontal movement
	var direction = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	velocity.x = direction * move_speed

	# Gravity
	velocity.y += gravity * delta

	# Jump on platform
	if is_on_floor():
		velocity.y = -jump_force

	# Apply movement
	move_and_slide()
