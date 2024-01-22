extends TileMap
@onready var proc_gen_world = $".."

var GRID_SIZE = 32
var NUM_ROWS
var NUM_COLS

var is_corrupted_grid = [] # Boolean 2D array of NUM_ROWS * NUM_COLS
var arr_corrupted_tiles = []

var CORRUPTION_PROBABILITY =  0.1 # 0.05

var corrupted_tile = preload("res://Scenes/corrupt_tile.tscn")
var wood_tree = preload("res://Scenes/wood_tree.tscn")
var rock_stone = preload("res://Scenes/rock_stone.tscn")
var rock_ore = preload("res://Scenes/rock_ore.tscn")
var enemies = [preload("res://Scenes/ranged_plant.tscn"),
			   preload("res://Scenes/melee_plant.tscn")]

var ground_layer
var ground_decor
var ground_object_layer

@export var ui : CanvasLayer

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
	spawn_resources()
	$spread_timer.start()
	
	# Random spawning 
	var player = get_node("Player")
	var r = get_random_grid_pos()
	player.position = Vector2(r.x*GRID_SIZE + GRID_SIZE/2, r.y*GRID_SIZE + GRID_SIZE/2)

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
		var atlas_coord = get_cell_atlas_coords(ground_layer, position)
		if valid_spawn_pos(atlas_coord) and (get_cell_atlas_coords(ground_object_layer, position) == Vector2i(-1,-1)):
			return position
			
# a valid spawn is any atlas coordinate in the tilemap that is allowed
func valid_spawn_pos(pos):
	var invalid_atlas = [Vector2i(10,2), Vector2i(12,1)]
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
	# get tile to display
	var atlas_coords = get_cell_atlas_coords(ground_decor, Vector2i(nx, ny))
	if atlas_coords == Vector2i(-1, -1):
		atlas_coords = get_cell_atlas_coords(ground_layer, Vector2i(nx, ny))
	if atlas_coords == Vector2i(2,3) and randf() < 0.15:
		atlas_coords = [Vector2i(4,1), Vector2i(3,2), Vector2i(4,3)].pick_random()

	# Instantiate corrupt tile
	var corruption = corrupted_tile.instantiate()
	corruption.position = pos 
	# Set corrupted tile
	corruption.get_node("CorrosionTiles").set_cell(0, Vector2i(0,0), 2, atlas_coords)
	
	# Link signals
	corruption.clear.connect(on_corruption_clear)
	# Add instance to parent
	is_corrupted_grid[nx][ny] = true
	arr_corrupted_tiles.append(Vector2(nx, ny))
	add_child(corruption)

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
		print("spawned enemy at: " + str(r))
		if valid_spawn_pos(get_cell_atlas_coords(ground_layer, r)):
			# get random enemy
			var enemy = enemies.pick_random().instantiate()
			enemy.position = Vector2(r.x*GRID_SIZE + GRID_SIZE/2, r.y*GRID_SIZE + GRID_SIZE/2)
			num_enemies += 1
			add_child(enemy)
			$enemy_spawn_timer.wait_time = randi() % 15 + 10

func _on_spread_timer_timeout():
	update_grid()
