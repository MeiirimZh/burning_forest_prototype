extends Node3D

# Nodes
@onready var dtimer = $DisappearanceTimer
@onready var ray = $RayCast3D

# Physics variables
@export var speed := 8.0

# Variables
@export var disappearance_time := 2.0
var direction := 1

func _ready() -> void:
	dtimer.start(disappearance_time)
	if direction == 1:
		rotation.y = 0
	else:
		rotation.y = 180

func _physics_process(delta: float) -> void:
	position.x += direction * speed * delta
	if ray.is_colliding():
		ray.enabled = false
		if ray.get_collider().is_in_group("enemy"):
			ray.get_collider().hit()
		queue_free()

func _on_disappearance_timer_timeout() -> void:
	queue_free()
