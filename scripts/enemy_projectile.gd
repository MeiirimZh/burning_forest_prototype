extends Node3D

# Nodes
@onready var ray = $RayCast3D
@onready var dtimer = $DisappearanceTimer

# Physics variables
@export var speed := 8.0

# Variables
var direction := -1
var type := 'straight'
@export var disappearance_time := 2.0

# Functions
func _ready() -> void:
	dtimer.start(disappearance_time)

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

func _on_disappearance_timer_timeout() -> void:
	queue_free()
