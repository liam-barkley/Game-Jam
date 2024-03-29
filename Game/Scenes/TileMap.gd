extends TileMap
@onready var proc_gen_world = $".."
@onready var game_music = $"../game_music"
@onready var player = $Player
@export var ui : CanvasLayer
@onready var label_2 = $"../UI/Label2"
@onready var spread_timer = $spread_timer

var GRID_SIZE = 32
var NUM_ROWS
var NUM_COLS

var is_corrupted_grid = [] # Boolean 2D array of NUM_ROWS * NUM_COLS
var arr_corrupted_tiles = []
var arr_spawnable_tiles = []
var arr_sand_tiles = []
var arr_grass_tiles = []

var num_trees = 0
var num_stones = 0
var num_ores = 0
var num_batteries = 0

var MAX_TREES = 15
var MAX_STONES = 15
var MAX_ORES = 15
var MAX_BATTERIES = 5


var CORRUPTION_PROBABILITY =  0.15 # 0.05

var corrupted_tile = preload("res://Scenes/corrupt_tile.tscn")
var wood_tree = preload("res://Scenes/wood_tree.tscn")
var rock_stone = preload("res://Scenes/rock_stone.tscn")
var rock_ore = preload("res://Scenes/rock_ore.tscn")
var battery = preload("res://Scenes/battery.tscn")
var enemies = [preload("res://Scenes/ranged_plant.tscn"),
			   preload("res://Scenes/melee_plant.tscn"),
			   preload("res://Scenes/healer_plant.tscn")]

var ground_layer
var ground_decor
var ground_object_layer

enum states {BEACH, GRASS, CORRUPTION}

var game_just_started = true

# music states
var current_state:
	set(value):
		if not game_just_started:
			current_state = value
			await get_tree().create_timer(2.0).timeout
			# Check if the current state is still the same after the delay
			if current_state != value:
				return
		game_just_started = false
		match value:
			states.BEACH:
				if game_music.stream != preload("res://Music/Beachy_background_V1.mp3"):
					game_music.stream = preload("res://Music/Beachy_background_V1.mp3")
					game_music.volume_db = 0
					game_music.play()
			states.GRASS:
				if game_music.stream != preload("res://Music/Ominous_background_V1.mp3"):
					game_music.stream = preload("res://Music/Ominous_background_V1.mp3")
					game_music.volume_db = -12
					game_music.play()
			states.CORRUPTION:
				if game_music.stream != preload("res://Music/Death_March.mp3"):
					game_music.stream = preload("res://Music/Death_March.mp3")
					game_music.volume_db = -10
					game_music.play()

var is_player_in_corruption : bool = false
var num_enemies : int = 0

func _ready():
	# get resources from parent
	await proc_gen_world.ready
	NUM_ROWS = proc_gen_world.height
	NUM_COLS = proc_gen_world.width
	ground_layer = proc_gen_world.ground_layer
	ground_decor = proc_gen_world.ground_decor
	ground_object_layer = proc_gen_world.ground_object_layer

	# initialization
	initialize_grid()
	initialize_resources()
	$spread_timer.start()
	
	# Random spawning 
	var player = get_node("Player")
	var r = get_random_grid_pos()
	player.position = Vector2(r.x*GRID_SIZE + GRID_SIZE/2, r.y*GRID_SIZE + GRID_SIZE/2)
	
func _process(delta):
	var player_pos = Vector2i(player.position)
	var tile = Vector2i(player_pos.x/GRID_SIZE, player_pos.y/GRID_SIZE)
	
	label_2.text = ("(" + str(player_pos.x/GRID_SIZE) + "," + str(player_pos.y/GRID_SIZE) + ")")

	# set state
	if not is_corrupted_grid[tile.x][tile.y]:
		var atlas_coord = get_cell_atlas_coords(ground_layer, tile)
		if current_state != states.GRASS and atlas_coord.y <= 3:
			current_state = states.GRASS
		elif current_state != states.BEACH and atlas_coord.y > 3:
			current_state = states.BEACH
			
	# slow corruption
	var size = arr_corrupted_tiles.size()
	if size < 5 and spread_timer.wait_time != 5:
		spread_timer.wait_time = 5
	elif arr_corrupted_tiles.size() % 2 == 0 and size < 200 and spread_timer.wait_time != arr_corrupted_tiles.size() * 0.02 + 4.5:
		spread_timer.wait_time = arr_corrupted_tiles.size() * 0.02 + 4.5
	elif size >= 200 and spread_timer.wait_time != 12:
		spread_timer.wait_time = 12
		
	if arr_corrupted_tiles.size() == 0:
		ui.victory.emit()
	
func initialize_grid():
	# Initialize 2d array
	for x in range(NUM_ROWS):
		var row = []
		for y in range(NUM_COLS):
			row.append(false)
			# tiles
			position = Vector2i(x, y)
			var atlas_coord = get_cell_atlas_coords(ground_layer, position)
			var source_id = get_cell_source_id(ground_layer, position)
			if source_id == proc_gen_world.source:
				# check for obstacles
				if get_cell_atlas_coords(ground_object_layer, position) == Vector2i(-1,-1):
					# set spawnable tiles
					if valid_spawn_pos(atlas_coord):
						arr_spawnable_tiles.append(position)
						# set sand and grass tiles
						if atlas_coord.y <= 3:
							arr_grass_tiles.append(position)
						elif atlas_coord .y > 3:
							arr_sand_tiles.append(position)

		is_corrupted_grid.append(row)
	
	# Randomly assign one corrupted tile
	var pos = get_random_grid_pos()
	add_corruption(pos.x, pos.y)
	print("Corruption spawned at: " + str(Vector2i(pos.x, pos.y)))

func initialize_resources():
	var low = 5
	# spawn wood
	for i in (randi() % MAX_TREES + 1 + low):
		spawn_tree()
	## spawn stone
	for i in (randi() % MAX_STONES + low):
		spawn_stone()
	# spawn ore
	for i in (randi() % MAX_ORES + low):
		spawn_ore()

func spawn_tree():
	if num_trees < MAX_TREES:
		var r = arr_grass_tiles.pick_random()
		var tree = wood_tree.instantiate()
		tree.position = Vector2(r.x*GRID_SIZE + GRID_SIZE/2, r.y*GRID_SIZE + GRID_SIZE/2)
		tree.gathered_wood.connect(ui._on_wood_tree_gathered_wood)
		num_trees += 1
		add_child(tree)

func spawn_stone():
	if num_stones < MAX_STONES:
		var r = get_random_grid_pos()
		var stone = rock_stone.instantiate()
		stone.position = Vector2(r.x*GRID_SIZE + GRID_SIZE/2, r.y*GRID_SIZE + GRID_SIZE/2)
		stone.gathered_stone.connect(ui._on_rock_stone_gathered_stone)
		stone.gathered_stone.connect(on_stone_gathered_stone)
		num_stones += 1
		add_child(stone)

func spawn_ore():
	if num_ores < MAX_ORES:
		var r = arr_sand_tiles.pick_random()
		var ore = rock_ore.instantiate()
		ore.position = Vector2(r.x*GRID_SIZE + GRID_SIZE/2, r.y*GRID_SIZE + GRID_SIZE/2)
		ore.gathered_ore.connect(ui._on_rock_ore_gathered_ore)
		ore.gathered_ore.connect(on_ore_gathered_ore)
		num_ores += 1
		add_child(ore)
		
func spawn_battery():
	if num_batteries < MAX_BATTERIES:
		var r = arr_sand_tiles.pick_random()
		var bat = battery.instantiate()
		bat.position = Vector2(r.x*GRID_SIZE + GRID_SIZE/2, r.y*GRID_SIZE + GRID_SIZE/2)
		bat.gathered_battery.connect(ui._on_battery_gathered_battery)
		bat.gathered_battery.connect(on_battery_gathered_battery)
		num_batteries += 1
		add_child(bat)
		print(r)

func on_stone_gathered_stone():
	num_stones -= 1

func on_ore_gathered_ore():
	num_ores -= 1

func on_battery_gathered_battery():
	num_batteries -= 1

# get a random position to spawn an entity
func get_random_grid_pos():
	return arr_spawnable_tiles.pick_random()

# a valid spawn is any atlas coordinate in the tilemap that is allowed
func valid_spawn_pos(pos):
	var invalid_atlas = [Vector2i(11,7)]
	return not invalid_atlas.has(pos)
#
func update_grid():
	var arr_corruption = arr_corrupted_tiles.duplicate(true)
	for corrupt_tile in arr_corruption:
		spread_corruption(corrupt_tile.x, corrupt_tile.y)
#
func spread_corruption(x, y):
	
	if is_corrupted_grid[x][y] == false:
		return

	# Spread corruption to neighboring tiles
	for i in range(-1, 2):
		for j in range(-1, 2):

			var nx = x + i
			var ny = y + j
			
			if nx >= 0 and nx < NUM_ROWS and ny >= 0 and ny < NUM_COLS:
				# skip already corrupted tiles:
				if is_corrupted_grid[nx][ny] == true:
					continue
				# do not spread corruption to water:
				var atlas_coord = get_cell_atlas_coords(ground_layer, Vector2i(nx, ny))
				if !valid_spawn_pos(atlas_coord):
					continue
				# randomly decide wheter to spread to tile:
				if randf() < CORRUPTION_PROBABILITY:
					add_corruption(nx, ny)

# NB need to pass in tilemap coordinate
func add_corruption(nx, ny):
	# Get vectors
	var pos = Vector2(nx * GRID_SIZE, ny * GRID_SIZE)
	var ground_atlas = get_cell_atlas_coords(ground_layer, Vector2i(nx, ny))

	# Instantiate corrupt tile
	var corruption = corrupted_tile.instantiate()
	corruption.position = pos 
	
	# Set corrupted tile

	var atlas_coords = get_cell_atlas_coords(ground_layer, Vector2i(nx, ny))
	corruption.get_node("CorrosionTiles").set_cell(0, Vector2i(0,0), proc_gen_world.source_corruption, atlas_coords)

	atlas_coords = get_cell_atlas_coords(ground_decor, Vector2i(nx, ny))
	if atlas_coords != Vector2i(-1, -1):
		corruption.get_node("CorrosionTiles").set_cell(1, Vector2i(0,0), proc_gen_world.source_corruption, atlas_coords)
	# Link signals
	corruption.clear.connect(on_corruption_clear)
	corruption.body_entered.connect(on_corruption_body_entered)
	# Add instance to parent
	is_corrupted_grid[nx][ny] = true
	arr_corrupted_tiles.append(Vector2(nx, ny))
	add_child(corruption)

func on_corruption_body_entered(body):
	if body.name == "Player":
		if current_state != states.CORRUPTION:
			current_state = states.CORRUPTION

func on_corruption_clear(corruption):
	var nx = corruption.position.x / GRID_SIZE
	var ny = corruption.position.y / GRID_SIZE
	
	is_corrupted_grid[nx][ny] = false
	arr_corrupted_tiles.erase(Vector2(nx, ny))
	print("Corruption cleared at: ", Vector2i(nx, ny))

func _on_enemy_spawn_timer_timeout():
	var num_corrupt_tiles = arr_corrupted_tiles.size()
	var FRAC = 3

	if num_enemies < num_corrupt_tiles / FRAC && arr_corrupted_tiles.size() > 0:
		# get random corruption tile
		var r = arr_corrupted_tiles.pick_random()
		# print("spawned enemy at: " + str(r))
		if valid_spawn_pos(get_cell_atlas_coords(ground_layer, r)):
			# get random enemy
			var enemy = enemies.pick_random().instantiate()
			enemy.position = Vector2(r.x*GRID_SIZE + GRID_SIZE/2, r.y*GRID_SIZE + GRID_SIZE/2)
			num_enemies += 1
			add_child(enemy)
			$enemy_spawn_timer.wait_time = randi() % 11 + 5

func _on_spread_timer_timeout():
	update_grid()

func _on_resource_spawn_timer_timeout():
	var arr_spawn = []
	
	if num_trees < MAX_TREES:
		arr_spawn.append(spawn_tree)
	if num_stones < MAX_STONES:
		arr_spawn.append(spawn_stone)
	if num_ores < MAX_ORES:
		arr_spawn.append(spawn_ore)
		
	if arr_corrupted_tiles.size() > 50 and num_batteries < MAX_BATTERIES:
		arr_spawn.append(spawn_battery)
	
	if arr_spawn.size() > 0:
		arr_spawn.pick_random().call()
	
	$resource_spawn_timer.wait_time = randi() % 10 + 5


func _on_game_music_finished():
	game_music.play()
