extends CanvasLayer

@export var player: CharacterBody2D

@onready var player_health_bar = %PlayerHealthBar

@onready var rock_label = %RockLabel
@onready var ore_label = %OreLabel
@onready var wood_label = %WoodLabel

var num_wood = 0:
	set(new_wood):
		num_wood = new_wood
		update_wood_label()

var num_rock = 0:
	set(new_rock):
		num_rock = new_rock
		update_rock_label()

var num_ore = 0:
	set(new_ore):
		num_ore = new_ore
		update_ore_label()

func _ready():
	await player != null
	player.health_changed.connect(update_health_progress)

	update_health_progress()
	update_rock_label()
	update_ore_label()

func update_health_progress():
	player_health_bar.value = player.health * 100 / player.max_health

func update_wood_label():
	wood_label.text = str(num_wood)

func update_rock_label():
	rock_label.text = str(num_rock)
	
func update_ore_label():
	ore_label.text = str(num_ore)

func _on_wood_tree_gathered_wood():
	num_wood += 1

func _on_rock_stone_gathered_stone():
	num_rock += 1

func _on_rock_ore_gathered_ore():
	num_ore += 1
