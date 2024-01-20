extends Area2D

signal clear(corruption)

func _on_area_entered(area):
	if area.is_in_group("pure"):
		clear.emit(self)
		queue_free()
