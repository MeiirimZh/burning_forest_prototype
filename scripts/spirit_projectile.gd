extends Area3D

# Physics variables
@export var speed := 7.0

# Variables
var direction := 1

func _physics_process(delta: float) -> void:
	position.x += direction * speed * delta
