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

func _physics_process(delta: float) -> void:
	position.x += direction * speed * delta
	if ray.is_colliding():
		queue_free()

func _on_disappearance_timer_timeout() -> void:
	queue_free()
