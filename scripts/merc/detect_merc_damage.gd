extends Area3D

# Variables
@export var damage := 1

# Signals
signal merc_damage_taken(dam)

func hit():
	emit_signal("merc_damage_taken", damage)
