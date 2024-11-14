extends Area3D

@export var damage := 1

signal spirit_damage_taken(dam)

func hit():
	emit_signal("spirit_damage_taken", damage)
