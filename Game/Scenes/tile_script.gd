extends TileMap

var GRID_SIZE = 16 # 16x16 will need to be changed to 32x32
var NUM_ROWS = 15
var NUM_COLS = 15
var is_corrupted_grid = [] # Boolean 2D array of NUM_ROWS * NUM_COLS

var corruption_probability = 0.025
var corrupted_tile = preload("res://Scenes/corrupt_tile.tscn")

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
		if  r < corruption_probability:
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

				if randf() < corruption_probability:
					is_corrupted_grid[nx][ny] = true
					# Instantiate corrupt tile
					var pos = Vector2(nx * GRID_SIZE, ny * GRID_SIZE)
					var corruption = corrupted_tile.instantiate()
					corruption.position = pos 
					add_child(corruption)
