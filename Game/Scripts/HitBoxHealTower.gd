extends Area2D

signal damage(amount)

func take_damage(amount):
	emit_signal("damage", amount)
