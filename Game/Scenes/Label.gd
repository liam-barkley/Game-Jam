extends Label

@export var tilemap : TileMap
@export var player : CharacterBody2D
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var player_pos = Vector2i(player.position)
	text = ("(" + str(player_pos.x/32) + "," + str(player_pos.y/32) + ")")
