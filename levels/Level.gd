extends Node2D

@onready var width: = get_viewport_rect().size.x
@onready var height: = get_viewport_rect().size.y

@onready var player: = $Player
@onready var platform_parent: = $Platforms
@onready var threshold: = height * 0.5
@onready var background:Sprite2D = $"ParallaxBackground/ParallaxLayer/Sprite2D"

# Load platform asset
var platform: = preload("res://objects/Platform.tscn")
# Initialize platform variables
var platform_count: = 5
var platforms: = []
# Initialize game scroll speed
var scrollSpeed = 0.05


func _ready()->void:
	# Set initial player height to middle of screen
	player.global_position.y = threshold
	for i in platform_count:
		# Create new platform instance for each platform
		var inst: = platform.instantiate()
		# Set height of new platform
		inst.global_position.y = height / platform_count * i
		# Set x postition of new platform to random value
		inst.global_position.x = rand_x()
		platform_parent.add_child(inst)
		platforms.append(inst)
	# Put initial platform under player
	player.global_position.x = rand_x()
	platforms.back().global_position.x = player.global_position.x

# Generate random x position between 28 and width-28
func rand_x():
	return randf_range(28, width-28)

func _physics_process(delta):
	if player.global_position.y < threshold:
		# Set amount to move background to linear interpolation of these values
		var move:float = lerp(0.0, threshold -player.global_position.y, scrollSpeed)
		move_background(move)
		# Move player position by previously determined amount
		player.global_position.y += move
		for plat in platforms:
			# Move player position by previously determined amount
			plat.global_position.y += move
			# If platform position is greater than screen height,
			# then subtract screen height from position and set x to random value
			if plat.global_position.y > height:
				plat.global_position.y -= height
				plat.global_position.x = rand_x()
	if player.global_position.y > height:
		game_over()

func move_background(move):
	var ratio: = 0.75
	background.global_position.y = fmod((background.global_position.y + height + move*ratio), height) - height

func game_over()->void:
	get_tree().reload_current_scene()
