extends Area3D

# Physics variables
@export var speed := 8.0

# Variables
var direction := -1
var type := 'straight'

# Functions
func move(delta):
	position.x += direction * speed * delta
	if type == 'up':
		position.y += speed * delta

func _physics_process(delta: float) -> void:
	move(delta)
