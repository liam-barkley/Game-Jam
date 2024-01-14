extends Sprite2D

@export var DAMAGE = 2

func _on_hurtbox_damage(amount):
	print("Hit for " +str(amount) +" of damage!")


func _on_hurtbox_area_entered(area):
	if area.is_in_group("hurtbox"):
		area.take_damage(DAMAGE)
