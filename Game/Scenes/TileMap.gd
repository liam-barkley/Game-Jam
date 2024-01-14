extends TileMap

var NUM_ROWS = 15
var NUM_COLS = 15
var boolean_2d_array = []

var corruption_probability = 0.025

var clean_tile = Vector2i(0,0)
var corrupted_tile = Vector2i(7,1)

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
		boolean_2d_array.append(row)

	## Set up the grid with an initial state
	#for x in range(NUM_ROWS):
		#for y in range(NUM_COLS):
			#var tile = Vector2(x,y)
			#set_cell(0, tile , 0, clean_tile)
	
	# Randomly assign one corrupted tile
	var corrupt_init = false
	var nx = 0 
	var ny = 0
	while corrupt_init == false:
		
		#print("(" + str(nx) + "," + str(ny) + ")\n")
		var r = randf()
		if  r < corruption_probability:
			var tile = Vector2(nx,ny)
			set_cell(0, tile , 0, corrupted_tile)
			boolean_2d_array[nx][ny] = true
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
	#print(str(x) + " " + str(y))
	if boolean_2d_array[x][y] == false:
		return
	#print("Corrupted tile!")
	# Spread corruption to neighboring tiles
	for i in range(-1, 2):
		for j in range(-1, 2):
			var nx = x + i
			var ny = y + j

			if nx >= 0 and nx < NUM_ROWS and ny >= 0 and ny < NUM_COLS:
				# Skip the center tile (self)
				if i == 0 and j == 0:
					continue
				var r = randf()
				#print(r)
				if r < corruption_probability && boolean_2d_array[nx][ny] == false:
					var tile = Vector2(nx,ny)
					set_cell(2, tile , 0, corrupted_tile)
					boolean_2d_array[nx][ny] = true


