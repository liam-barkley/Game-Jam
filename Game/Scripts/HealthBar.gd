extends TextureProgressBar

@export var player: CharacterBody2D

func _ready():
	await player.ready
	player.health_changed.connect(update)
	update()

func update():
	value = player.health * 100 / player.max_health
