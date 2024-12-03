extends CharacterBody3D

# Nodes
@onready var player = get_node("/root/World/Spirit")

# Physics variables
@export var speed := 8.0
@export var jump_force := 15.0
@export var gravity := 30.0

# Variables
var is_moving := false
var jump := true
var is_attacking := false
var momentum := false
var last_direction := -1

func set_direction():
	if player.position.x < position.x:
		return -1
	else:
		return 1

func _physics_process(delta: float) -> void:
	var direction = 0
	
	direction = set_direction()
		
	if abs(position.x - player.position.x) <= 4.0 and is_on_floor() and jump:
		is_attacking = true
		velocity.y = jump_force
	
	if is_moving and not is_attacking:
		velocity.x = speed * direction
	elif is_moving and is_attacking:
		velocity.x = speed
	else:
		velocity.x = 0
	
	if is_on_floor():
		if is_attacking:
			jump = false
			is_attacking = false
	else:
		velocity.y -= gravity * delta
		
	move_and_slide()

func _on_detect_player_body_entered(body: Node3D) -> void:
	if body.name == "Spirit":
		is_moving = true
