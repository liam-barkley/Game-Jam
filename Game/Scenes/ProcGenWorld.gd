extends Node2D

@onready var tile_map = $TileMap
@export var noise_height_text : NoiseTexture2D 

var num_wood : int = 0

func _on_wood_tree_gathered_wood():
	num_wood += 1
	print(num_wood)

var source = 1
var GRASS_PROBABILITY = 0.25
var SAND_PROBABILITY = 0.15
var TREE_PROBABILITY = 0.05
var ROCK_PROBABILITY = 0.01

var grass_atlas_arr = [Vector2i(1,2), Vector2i(2,1)]
var tree_atlas_arr = [Vector2i(1,3), Vector2i(2,4), Vector2i(3,3)]
var sand_atlas_arr = [Vector2i(15,1), Vector2i(15,2), Vector2i(15,3), Vector2i(15,4)]
var light_water_atlas = Vector2i(10,2)
var dark_water_atlas = Vector2i(12,1)
var sand_atlas = Vector2i(4,3)
var grass_atlas = Vector2i(3,2)
var rock_atlas = Vector2i(4,4)

var ground_layer = 0
var ground_decor = 1
var corruption_layer = 2
var ground_object_layer = 3

var sand_terrain_idx = 0
var grass_terrain_idx = 1
var lightwater_terrain_idx = 2

var _tiles_arr = []
var lightwater_tiles_arr = []
var sand_tiles_arr = []
var grass_tiles_arr = []

var noise : Noise

var width = 50
var height = 50
var center_x = width / 2
var center_y = height / 2

var noise_val_array = []

func _ready():
	noise = noise_height_text.noise
	noise.seed = randi()
	gen_world()
	
func gen_world():
	
	for y in range(width):
		for x in range(height):
			# circle distance
			var distance = sqrt(pow(x - center_x, 2) + pow(y - center_y, 2))
			var pos = Vector2i(x, y)
			
			# debug info
			var noise_val = noise.get_noise_2d(x, y)
			noise_val_array.append(noise_val)

			# dark water
			tile_map.set_cell(0, pos, source, dark_water_atlas)

			# outer shallow water random
			if distance <= min(center_x, center_y) + 4 and distance > min(center_x, center_y) + 1:
				if noise_val > 0.4:
					lightwater_tiles_arr.append(pos)
			# light water boundary
			if distance <= min(center_x, center_y) + 1:
				tile_map.set_cell(0, pos, source, light_water_atlas)
			
			# outer beach random
			if distance <= min(center_x, center_y) - 1 and distance > min(center_x, center_y) - 3 :
				if noise_val > 0.4:
					sand_tiles_arr.append(pos)
					if randf() < SAND_PROBABILITY:
						tile_map.set_cell(ground_decor, pos, source, sand_atlas_arr.pick_random())
			# beach boundary
			if distance <= min(center_x, center_y) - 3 and distance >= min(center_x, center_y) - 6:
				sand_tiles_arr.append(pos)
				if randf() < ROCK_PROBABILITY:
					tile_map.set_cell(ground_object_layer, pos, source, rock_atlas)
			
			# inner island with noise map
			if distance <= min(center_x, center_y) - 6:
				# sand
				if noise_val < 0:
					lightwater_tiles_arr.append(pos)
				if noise_val > -0.2:
					sand_tiles_arr.append(pos)
					if randf() < SAND_PROBABILITY and noise_val <= 0:
						tile_map.set_cell(ground_decor, pos, source, sand_atlas_arr.pick_random())
					# grass
					if noise_val > 0:
						grass_tiles_arr.append(pos)
						if randf() < GRASS_PROBABILITY:
							tile_map.set_cell(ground_decor, pos, source, grass_atlas_arr.pick_random())
						if randf() < TREE_PROBABILITY:
							tile_map.set_cell(ground_object_layer, pos, source, tree_atlas_arr.pick_random())
						if randf() < ROCK_PROBABILITY:
							tile_map.set_cell(ground_object_layer, pos, source, rock_atlas)

	tile_map.set_cells_terrain_connect(ground_layer, lightwater_tiles_arr, lightwater_terrain_idx, 0)
	tile_map.set_cells_terrain_connect(ground_layer, sand_tiles_arr, sand_terrain_idx, 0)
	tile_map.set_cells_terrain_connect(ground_layer, grass_tiles_arr, grass_terrain_idx, 0)

	# debug info
	print("high: ", noise_val_array.max())
	print("low ", noise_val_array.min())

