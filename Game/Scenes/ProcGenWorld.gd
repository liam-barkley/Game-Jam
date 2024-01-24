extends Node2D

@onready var tile_map = $TileMap
@onready var ui = $UI
@onready var player = $TileMap/Player

@export var noise_height_text : NoiseTexture2D 

var num_wood : int = 0

var source = 8
var source_corruption = 0
var GRASS_PROBABILITY = 0.25
var FOREST_PROBABILITY = 0.05
var SAND_PROBABILITY = 0.05
var TREE_PROBABILITY = 0.05
var ROCK_PROBABILITY = 0.01

var grass_atlas_arr = [Vector2i(14,0), Vector2i(14,1)]
var forest_atlas_arr =  [Vector2i(14,2), Vector2i(14,3)]
var tree_atlas_arr = [Vector2i(15,4), Vector2i(15,5), Vector2i(15,6)]
var sand_atlas_arr = [Vector2i(14,4), Vector2i(14,5), Vector2i(14,6), Vector2i(14,7)]
var light_water_atlas = Vector2i(11,7)
#var sand_atlas = Vector2i(4,3)
#var grass_atlas = Vector2i(3,2)
var rock_atlas = [Vector2i(16,4), Vector2i(16,5), Vector2i(16,6)]

var ground_layer = 0
var ground_decor = 1
var ground_object_layer = 2

var sand_terrain_idx = 0
var grass_terrain_idx = 1

var lightwater_tiles_arr = []
var sand_tiles_arr = []
var grass_tiles_arr = []

var noise : Noise

var width = 50
var height = 50
var grid_size = 32
var center_x = width / 2
var center_y = height / 2

var noise_val_array = []

func _ready():
	noise = noise_height_text.noise
	noise.seed = randi()
	gen_world()
	
func _process(delta):
	
	# manage towers
	if Input.is_action_just_pressed("build"):
		var mouse_pos = get_local_mouse_position()
		var player_pos = player.position

		# building radius
		var distance = sqrt(pow(mouse_pos.x - player_pos.x, 2) + pow(mouse_pos.y - player_pos.y, 2))
		if distance >= 3 * grid_size:
			print("Not in build radius")
			return

		# check for sufficient resources
		if not ui.build_selected_tower():
			return
		# place tower that has been built
		var building = ui.TOWER_SCENES[ui.tower_selected].instantiate()
		building.position = mouse_pos
		add_child(building)

func gen_world():
	
	for y in range(width):
		for x in range(height):
			# circle distance
			var distance = sqrt(pow(x - center_x, 2) + pow(y - center_y, 2))
			var pos = Vector2i(x, y)
			
			# debug info
			var noise_val = noise.get_noise_2d(x, y)
			noise_val_array.append(noise_val)
			
			# outer beach random
			if distance <= min(center_x, center_y) - 1 and distance > min(center_x, center_y) - 2 :
				if noise_val > 0.4:
					sand_tiles_arr.append(pos)
					if randf() < SAND_PROBABILITY:
						tile_map.set_cell(ground_decor, pos, source, sand_atlas_arr.pick_random())
			# beach boundary
			if distance <= min(center_x, center_y) - 2 and distance >= min(center_x, center_y) - 6:
				sand_tiles_arr.append(pos)
				if randf() < ROCK_PROBABILITY:
					tile_map.set_cell(ground_object_layer, pos, source, rock_atlas.pick_random())
				if randf() < SAND_PROBABILITY:
						tile_map.set_cell(ground_decor, pos, source, sand_atlas_arr.pick_random())
			
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
						if randf() < FOREST_PROBABILITY:
							tile_map.set_cell(ground_decor, pos, source, forest_atlas_arr.pick_random())
						if randf() < TREE_PROBABILITY:
							tile_map.set_cell(ground_object_layer, pos, source, tree_atlas_arr.pick_random())
						if randf() < ROCK_PROBABILITY:
							tile_map.set_cell(ground_object_layer, pos, source, rock_atlas.pick_random())

	tile_map.set_cells_terrain_connect(ground_layer, sand_tiles_arr, sand_terrain_idx, 0)
	tile_map.set_cells_terrain_connect(ground_layer, grass_tiles_arr, grass_terrain_idx, 0)

	# debug info
	#print("high: ", noise_val_array.max())
	#print("low ", noise_val_array.min())
	
