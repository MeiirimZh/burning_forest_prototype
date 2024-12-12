extends Area3D

# Variables
@export var damage := 1

# Signals
signal spirit_damage_taken(dam)

func hit():
	emit_signal("spirit_damage_taken", damage)
