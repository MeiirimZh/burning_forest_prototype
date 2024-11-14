extends Node3D

# Nodes
@onready var ray = $RayCast3D

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
	if ray.is_colliding():
		ray.enabled = false
		if ray.get_collider().is_in_group("spirit"):
			ray.get_collider().hit()
		queue_free()
