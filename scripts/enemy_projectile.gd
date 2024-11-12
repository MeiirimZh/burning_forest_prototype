extends Area3D

# Physics variables
@export var h_speed := 8.0
@export var v_speed := 0

# Variables
var direction := -1

# Functions
func move(delta, y=0):
	position.x += direction * h_speed * delta
	position.y += direction * y * delta

func _physics_process(delta: float) -> void:
	move(delta, v_speed)
