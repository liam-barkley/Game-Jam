extends CanvasLayer

@export var player: CharacterBody2D

@onready var player_health_bar = %PlayerHealthBar

@onready var rock_label = %RockLabel
@onready var ore_label = %OreLabel
@onready var wood_label = %WoodLabel
@onready var battery_label = %BatteryLabel
@onready var label = $Control/MarginContainer/MarginContainer/BoxContainer/PlayerHealthBar/Label
@onready var option_button = $Control/OptionButton

var tower_selected : int = 0

var TOWER_SCENES = [preload("res://Scenes/healing_tower.tscn"), 
					preload("res://Scenes/purifying_tower.tscn"),
					preload("res://Scenes/ranged_tower.tscn")]
# drop down index for towers
var HEALER_IDX = 0
var PURIFIER_IDX = 1
var RANGED_IDX = 2

# resources for towers [wood, rock, ore, battery]
var healer_resources = [3, 1, 0, 0]
var purifier_resources = [0, 2, 2, 1]
var ranged_resources = [2, 2, 1, 0]

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

var num_battery = 0:
	set(new_battery):
		num_battery = new_battery
		update_battery_label()

func _ready():
	await player != null
	player.health_changed.connect(update_health_progress)

	update_health_progress()
	update_rock_label()
	update_ore_label()
	update_battery_label()
	update_dropdown()

func build_selected_tower():
	match tower_selected:
			HEALER_IDX: # healing tower
				if not build_tower(healer_resources):
					print("Not enough resources for healer!")
					return
				print("Built healer!")
			PURIFIER_IDX:  # purifying tower
				if not build_tower(purifier_resources):
					print("Not enough resources for purifier!")
					return
				print("Built purifier!")
			RANGED_IDX: # ranged tower
				if not build_tower(ranged_resources):
					print("Not enough resources for ranged!")
					return
				print("Built ranged!")

	return true

func build_tower(required_resources):
	if check_sufficient_resources(required_resources):
		use_resources(required_resources)
		return true
	else:
		return false

func check_sufficient_resources(req):
	if num_wood >= req[0] && num_rock >= req[1] && num_ore >= req[2] && num_battery >= req[3]:
		return true
	else:
		return false
	
func use_resources(res):
	num_wood -= res[0]
	num_rock -= res[1]
	num_ore -= res[2]
	num_battery -= res[3]

func update_dropdown():
	var h = "Healer (%d wood, %d stone, %d ore)" % [healer_resources[0], healer_resources[1], healer_resources[2]]
	var p = "Purifier (%d wood, %d stone, %d ore, %d battery)" % [purifier_resources[0], purifier_resources[1], purifier_resources[2], purifier_resources[3]]
	var r = "Ranged (%d wood, %d stone, %d ore)" % [ranged_resources[0], ranged_resources[1], ranged_resources[2]]
	option_button.add_item(h, HEALER_IDX)
	option_button.add_item(p, PURIFIER_IDX)
	option_button.add_item(r, RANGED_IDX)
	
	# set healer active 
	option_button.selected = HEALER_IDX
	tower_selected = HEALER_IDX

func update_health_progress():
	player_health_bar.value = player.health * 100 / player.max_health
	if player.health <= 0:
		label.text = "0"
	else:
		label.text = str(player.health)

func update_wood_label():
	wood_label.text = str(num_wood)

func update_rock_label():
	rock_label.text = str(num_rock)
	
func update_ore_label():
	ore_label.text = str(num_ore)

func update_battery_label():
	battery_label.text = str(num_battery)

func _on_wood_tree_gathered_wood():
	num_wood += 1

func _on_rock_stone_gathered_stone():
	num_rock += 1

func _on_rock_ore_gathered_ore():
	num_ore += 1

func _on_battery_gathered_battery():
	num_battery += 1

func _on_option_button_item_selected(index):
	tower_selected = index
