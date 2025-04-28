extends CharacterBody2D

@export var jump_force = 6.5 * 60
@export var gravity: = 8.0 * 60
@export var speed = 3.0 * 60
var dir = 0.0
var was_boosted = false
var jetpack_timer = 0.0

@onready var screen_size = get_viewport_rect().size

# Function for screen wrapping
func screen_wrap():
	# Wrap right
	if position.x > screen_size.x:
		position.x = 0
	# Wrap left
	if position.x < 0:
		position.x = screen_size.x

func _physics_process(delta: float) -> void:
	# Jetpack override
	if jetpack_timer > 0:
		jetpack_timer -= delta
		velocity.y = -jump_force
	else:
		# gravity
		velocity.y += gravity * delta

	# Change direction based on input
	dir = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")

	# Bouncing on platforms
	if is_on_floor():
		if was_boosted:
			was_boosted = false
		else:
			velocity.y = -jump_force

	velocity.x = dir * speed
	move_and_slide()
	screen_wrap()

func _on_spring_activated():
	velocity.y = -500
	was_boosted = true

func _on_coffin_entered(body):
	if body == self:
		jetpack_timer = 2.0  # Jetpack lasts 2 seconds
