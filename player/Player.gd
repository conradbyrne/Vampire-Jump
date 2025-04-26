extends CharacterBody2D

@export var jump_force = 6.5 * 60
@export var gravity: = 8.0 * 60
@export var speed = 3.0 * 60
var dir = 0.0
var was_boosted = false

@onready var screen_size = get_viewport_rect().size

# Function for screen wrapping
func screen_wrap():
	# If player has moved beyond the right side of the screen, set position to left side
	if position.x > screen_size.x:
		position.x = 0
	# If player has moved beyond the left side of the screen, set position to right side
	if position.x < 0:
		position.x = screen_size.x

func _physics_process(delta:float)->void:
	# Change direction based on input
	dir = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	# gravity
	velocity.y += gravity*delta
	# bouncing on platforms
	if is_on_floor():
		if was_boosted:
			# If we were boosted, don't bounce again
			was_boosted = false
		else:
			# Normal bounce on platforms
			velocity.y = -jump_force
	
	velocity.x = dir * speed
	#set_velocity(velocity)
	move_and_slide()
	screen_wrap()
	
func _on_spring_activated():
	velocity.y = -1000  # Stronger negative value than normal jump
	was_boosted = true
