extends TileMap

var GRID_SIZE = 16 # 16x16 will need to be changed to 32x32
var NUM_ROWS = 15
var NUM_COLS = 15
var is_corrupted_grid = [] # Boolean 2D array of NUM_ROWS * NUM_COLS

var CORRUPTION_PROBABILITY = 0.025
var corrupted_tile = preload("res://Scenes/corrupt_tile.tscn")

var is_player_in_corruption : bool = false

func _ready():
	initialize_grid()
	$Timer.start()
	
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
	var corrupt_init = false
	var nx = 0 
	var ny = 0
	while corrupt_init == false:
		var r = randf()
		if  r < CORRUPTION_PROBABILITY:
			var pos = Vector2(nx*GRID_SIZE, ny*GRID_SIZE)
			var my_instance = corrupted_tile.instantiate()
			my_instance.position = pos 
			add_child(my_instance)
			is_corrupted_grid[nx][ny] = true
			corrupt_init = true

		if (ny+1)/NUM_COLS == 1:
			nx += 1
			nx %= NUM_ROWS
			ny = 0
		else:
			ny += 1
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
					is_corrupted_grid[nx][ny] = true
					# Instantiate corrupt tile
					var pos = Vector2(nx * GRID_SIZE, ny * GRID_SIZE)
					var corruption = corrupted_tile.instantiate()
					corruption.position = pos 
					# Set corrupted tile
					var tile = get_cell_atlas_coords(0, Vector2i(nx, ny))
					corruption.get_node("CorrosionTiles").set_cell(0, Vector2i(0,0), 2, tile)
					# Link signals
					corruption.body_entered.connect(on_corruption_body_entered)
					corruption.body_exited.connect(on_corruption_body_exited)
					# Add instance to parent
					add_child(corruption)

func on_corruption_body_entered(body):
	if body.name == "Player" && is_player_in_corruption == false:
		is_player_in_corruption = true
		print("Player has entered the corruption")

func on_corruption_body_exited(body):
	#if body.name == "Player" && is_player_in_corruption == true:
		#is_player_in_corruption = false
	pass
