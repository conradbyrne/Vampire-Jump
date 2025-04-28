extends Node2D

@onready var width           := get_viewport_rect().size.x
@onready var height          := get_viewport_rect().size.y
@onready var player          := $Player
@onready var platform_parent := $Platforms
@onready var enemy_parent    := $Enemies        # your new static container
@onready var threshold       := height * 0.5
@onready var background:Sprite2D = $"ParallaxBackground/ParallaxLayer/Sprite2D"
@onready var score_label     := $ScoreLabel

# Preloads
var platform     = preload("res://objects/Platform.tscn")
var jumpboost    = preload("res://objects/jump_boost.tscn")
var coin_scene   = preload("res://objects/Coin.tscn")
var witch_scene  = preload("res://objects/Witch.tscn")
var gargoyle_scene = preload("res://objects/Gargoyle.tscn")
var coffin_scene   = preload("res://objects/Coffin.tscn")

# Game state
var platform_count = 5
var platforms = []
var scrollSpeed = 0.05
var coin_score = 0
var total_scroll = 0.0
var consecutive_enemy_spawns = 0  # Track consecutive enemy spawns

const SPAWN_MARGIN = 32  # pixels from top/bottom edge
const MAX_CONSECUTIVE_ENEMIES = 1  # Maximum consecutive enemy spawns allowed

func _ready() -> void:
	# Place player in mid‐screen, randomize platforms, but DO NOT spawn yet
	player.global_position.y = threshold
	randomize()
	for i in range(platform_count):
		var inst = platform.instantiate()
		inst.global_position.y = height / platform_count * i
		inst.global_position.x = rand_x()
		inst.items_spawned = false   # flag on each Platform
		platform_parent.add_child(inst)
		platforms.append(inst)

func _physics_process(delta: float) -> void:
	if player.global_position.y < threshold:
		var move = lerp(0.0, threshold - player.global_position.y, scrollSpeed)
		move_background(move)
		player.global_position.y += move

		# Move enemies with the screen
		for enemy in enemy_parent.get_children():
			enemy.global_position.y += move
			
			# Remove enemies that go offscreen (opposite side)
			if (enemy.direction.x > 0 and enemy.global_position.x > width + 32) or \
			   (enemy.direction.x < 0 and enemy.global_position.x < -32):
				enemy.queue_free()

		# Gather only the platforms that wrapped this frame
		var wrapped := []
		for inst in platforms:
			inst.global_position.y += move
			if inst.global_position.y > height:
				inst.global_position.y -= height
				inst.global_position.x = rand_x()
				inst.items_spawned = false
				wrapped.append(inst)

		# Spawn exactly one item or enemy on one randomly chosen wrapped platform
		if wrapped.size() > 0:
			var pick = wrapped[randi() % wrapped.size()]
			spawn_items(pick)

		total_scroll += move
		var score = int(total_scroll) + coin_score
		score_label.text = "Score: " + str(score)

	if player.global_position.y > height:
		game_over()

func spawn_items(inst):
	if inst.items_spawned:
		return
	# clear old pickups/enemies
	for child in inst.get_children():
		if child is Area2D:
			child.queue_free()

	var r = randi() % 100
	
	# Adjust enemy spawn chance based on consecutive spawns
	var enemy_chance = 5
	if consecutive_enemy_spawns >= MAX_CONSECUTIVE_ENEMIES:
		enemy_chance = 0  # Force non-enemy spawn after max consecutive enemies
	
	if r < 10:
		# 10% jump boost
		var j = jumpboost.instantiate()
		j.position = Vector2(0, -10)
		inst.add_child(j)
		j.connect("spring_activated", Callable(player, "_on_spring_activated"))
		consecutive_enemy_spawns = 0  # Reset counter
		
	elif r < 35:
		# 25% coin
		var c = coin_scene.instantiate()
		c.position = Vector2(0, -20)
		inst.add_child(c)
		c.connect("coin_collected", Callable(self, "_on_coin_collected"))
		consecutive_enemy_spawns = 0  # Reset counter
		
	elif r < 50:
		# 15% coffin
		var f = coffin_scene.instantiate()
		f.position = Vector2(0, -10)
		inst.add_child(f)
		f.connect("body_entered", Callable(player, "_on_coffin_entered"))
		consecutive_enemy_spawns = 0  # Reset counter
		
	elif r < (50 + enemy_chance) and enemy_parent.get_child_count() < 4:
		# Spawn enemy (with a cap on consecutive spawns AND total enemy count)
		consecutive_enemy_spawns += 1
		
		var enemy
		if randi() % 2 == 0:
			enemy = witch_scene.instantiate()
			enemy.direction = Vector2(1, 0)
		else:
			enemy = gargoyle_scene.instantiate()
			enemy.direction = Vector2(-1, 0)

		# clamp its Y so it never clips
		var raw_y = inst.global_position.y - 10
		var spawn_y = clamp(raw_y, SPAWN_MARGIN, height - SPAWN_MARGIN)
		# off‐screen X based on direction
		var x_pos = -16 if enemy.direction.x > 0 else width + 16
		enemy.global_position = Vector2(x_pos, spawn_y)

		# anchor under the static Enemies node
		enemy_parent.add_child(enemy)
	else:
		# No item spawned (just an empty platform)
		consecutive_enemy_spawns = 0  # Reset counter

	inst.items_spawned = true

func rand_x():
	return randf_range(28, width - 28)

func move_background(move):
	var ratio = 0.75
	background.global_position.y = fmod(background.global_position.y + height + move*ratio, height) - height

func game_over() -> void:
	get_tree().reload_current_scene()

func _on_coin_collected(value):
	coin_score += value
