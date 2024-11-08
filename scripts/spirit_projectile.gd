extends Area3D

# Physics variables
@export var speed := 7.0

func _physics_process(delta: float) -> void:
	position.x += speed * delta
