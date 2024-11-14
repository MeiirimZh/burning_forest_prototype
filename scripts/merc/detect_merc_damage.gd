extends Area3D

# Variables
@export var damage := 1

# Signals
signal damage_taken(dam)

func hit():
	emit_signal("damage_taken", damage)
