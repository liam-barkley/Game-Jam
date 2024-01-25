extends TileMap

var GRID_SIZE = 32
var NUM_ROWS = 42
var NUM_COLS = 42
var is_corrupted_grid = [] # Boolean 2D array of NUM_ROWS * NUM_COLS
var arr_corrupted_tiles = []
var arr_idx = 0

var CORRUPTION_PROBABILITY = 0.025
var corrupted_tile = preload("res://Scenes/corrupt_tile.tscn")
var wood_tree = preload("res://Scenes/wood_tree.tscn")
var rock_stone = preload("res://Scenes/rock_stone.tscn")
var rock_ore = preload("res://Scenes/rock_ore.tscn")

var enemies = [preload("res://Scenes/ranged_plant.tscn"),
			   preload("res://Scenes/melee_plant.tscn")]

@export var ui : CanvasLayer

var is_player_in_corruption : bool = false
var num_enemies : int = 0

func _ready():
	initialize_grid()
	spawn_resources()
	$Timer.start()
	print(get_cell_atlas_coords(2, Vector2i(2,3)) == Vector2i(-1,-1))
	#$RangedPlant.position = Vector2i(224,224)
	
	# Random spawning 
	#var player = get_node("Player")
	#var r = get_random_grid_pos()
	#player.position = Vector2(r.x*GRID_SIZE + GRID_SIZE/2, r.y*GRID_SIZE + GRID_SIZE/2)
	
func _on_timer_timeout():
	update_grid()

func initialize_grid():
	# Initialize 2d array
	for x in range(NUM_ROWS):
		var row = []
		for y in range(NUM_COLS):
			row.append(false)
		is_corrupted_grid.append(row)
	
	# Randomly assign one corrupted tile
	var pos = get_random_grid_pos()
	add_corruption(pos.x, pos.y)
	print("Corruption spawned at: " + str(Vector2i(pos.x, pos.y)))

func spawn_resources():
	var l = 5
	var h = 15 + 1
	# spawn wood
	for i in (randi() % h + l):
		var r = get_random_grid_pos()
		var tree = wood_tree.instantiate()
		tree.position = Vector2(r.x*GRID_SIZE + GRID_SIZE/2, r.y*GRID_SIZE + GRID_SIZE/2)
		tree.gathered_wood.connect(ui._on_wood_tree_gathered_wood)
		add_child(tree)
	## spawn stone
	for i in (randi() % h + l):
		var r = get_random_grid_pos()
		var stone = rock_stone.instantiate()
		stone.position = Vector2(r.x*GRID_SIZE + GRID_SIZE/2, r.y*GRID_SIZE + GRID_SIZE/2)
		stone.gathered_stone.connect(ui._on_rock_stone_gathered_stone)
		add_child(stone)
	# spawn ore
	for i in (randi() % h + l):
		var r = get_random_grid_pos()
		var ore = rock_ore.instantiate()
		#print(str(i) + ": " + str(r))
		ore.position = Vector2(r.x*GRID_SIZE + GRID_SIZE/2, r.y*GRID_SIZE + GRID_SIZE/2)
		ore.gathered_ore.connect(ui._on_rock_ore_gathered_ore)
		add_child(ore)

# get a random position to spawn an entity
func get_random_grid_pos():
	var random = RandomNumberGenerator.new()
	random.randomize()
	# ensure spawn occurs on valid location
	while true:
		var x = random.randi_range(0, NUM_COLS-1)
		var y = random.randi_range(0, NUM_ROWS-1)
		position = Vector2i(x, y)
		var atlas_coord = get_cell_atlas_coords(0, position)
		if valid_spawn_pos(atlas_coord) and (get_cell_atlas_coords(2, position) == Vector2i(-1,-1)):
			return position
			
# a valid spawn is any atlas coordinate in the tilemap that is allowed
func valid_spawn_pos(pos):
	if pos.x == 10 and pos.y == 2:
		return false
	elif pos.x == 6:
		return false
	elif pos.x > 13:
		return false
	elif pos.x > 6 and (pos.y == 0 or pos.y == 6):
		return false
	
	return true 
#
func update_grid():
	for x in range(NUM_ROWS):
		for y in range(NUM_COLS):
			spread_corruption(x, y)
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
				# Skip the center tile (self) and corrupted tiles
				if (i == 0 and j == 0) || (is_corrupted_grid[nx][ny] == true):
					continue

				if randf() < CORRUPTION_PROBABILITY:
					add_corruption(nx, ny)

# NB need to pass in tilemap coordinate
func add_corruption(nx, ny):
	# Get vectors
	var pos = Vector2(nx * GRID_SIZE, ny * GRID_SIZE)
	var atlas_coords = get_cell_atlas_coords(0, Vector2i(nx, ny))
	# Instantiate corrupt tile
	var corruption = corrupted_tile.instantiate()
	corruption.position = pos 
	# Set corrupted tile
	corruption.get_node("CorrosionTiles").set_cell(0, Vector2i(0,0), 0, atlas_coords)
	# Link signals
	corruption.body_entered.connect(on_corruption_body_entered)
	corruption.body_exited.connect(on_corruption_body_exited)
	# Add instance to parent
	is_corrupted_grid[nx][ny] = true
	arr_corrupted_tiles.append(Vector2(nx, ny))
	arr_idx += 1
	add_child(corruption)

func on_corruption_body_entered(body):
	if body.name == "Player" && is_player_in_corruption == false:
		is_player_in_corruption = true
		print("Player has entered the corruption")

func on_corruption_body_exited(body):
	#if body.name == "Player" && is_player_in_corruption == true:
		#is_player_in_corruption = false
	pass

func _on_ranged_spawn_timer_timeout():
	var num_corrupt_tiles = arr_corrupted_tiles.size()
	var FRAC = 3

	if num_enemies < num_corrupt_tiles / FRAC:
		# get random corruption tile
		var i = randi() % num_corrupt_tiles
		var r = arr_corrupted_tiles[i]
		print("spawn: " + str(r))
		if valid_spawn_pos(get_cell_atlas_coords(0, r)):
			# get random enemy
			var enemy = enemies[randi() % enemies.size()].instantiate()
			enemy.position = Vector2(r.x*GRID_SIZE + GRID_SIZE/2, r.y*GRID_SIZE + GRID_SIZE/2)
			num_enemies += 1
			add_child(enemy)
			$ranged_spawn_timer.wait_time = randi() % 15 + 10
