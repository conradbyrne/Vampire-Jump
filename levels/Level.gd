extends Node2D

@onready var width: = get_viewport_rect().size.x
@onready var height: = get_viewport_rect().size.y

@onready var player: = $Player
@onready var platform_parent: = $Platforms
@onready var threshold: = height * 0.5
@onready var background:Sprite2D = $"ParallaxBackground/ParallaxLayer/Sprite2D"
@onready var score_label: = $ScoreLabel

# Load platform asset
var platform: = preload("res://objects/Platform.tscn")
var jumpboost := preload("res://objects/jump_boost.tscn")

# Initialize platform variables
var platform_count: = 5
var platforms: = []
# Initialize game scroll speed
var scrollSpeed = 0.05

#Score
var score = 0
var total_scroll = 0.0


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
		
		#  Randomly add a jump boost
		if randi() % 3 == 0:  # ~33% chance
			var jump_boost = jumpboost.instantiate()
			jump_boost.position = Vector2(0, -10)  # Position above the platform
			inst.add_child(jump_boost)

			# Connect signal
			jump_boost.connect("spring_activated", Callable(player, "_on_spring_activated"))
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
				
		total_scroll += move
		score = int(total_scroll)  # Or divide if score grows too fast
		$ScoreLabel.text = "Score: " + str(score)
	if player.global_position.y > height:
		game_over()

func move_background(move):
	var ratio: = 0.75
	background.global_position.y = fmod((background.global_position.y + height + move*ratio), height) - height

func game_over()->void:
	get_tree().reload_current_scene()
