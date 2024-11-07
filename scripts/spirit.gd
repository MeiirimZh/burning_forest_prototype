extends CharacterBody3D

# Nodes
@onready var animation_player = $AnimationPlayer
@onready var mesh = $Armature

# Physics variables
@export var speed := 7.0
@export var jump_force := 10.0
@export var gravity := 30.0

# Variables
@export var state := "r_idle"

# Rotate the mesh and play an animation 
func rotate_and_play(angle, animation):
	mesh.rotation.y = angle
	animation_player.play(animation)

func _physics_process(_delta) -> void:
	var direction = 0
	
	if state == "r_idle":
		rotate_and_play(0, "idle")
	elif state == "l_idle":
		rotate_and_play(85, "idle")
	elif state == "r_run":
		rotate_and_play(-92.5, "run")
	elif state == "l_run":
		rotate_and_play(92.5, "run")
	
	if Input.is_action_pressed("left"):
		direction = -1
		state = "l_run"
	elif Input.is_action_pressed("right"):
		direction = 1
		state = "r_run"
		
	if Input.is_action_just_released("left"):
		state = "l_idle"
	elif Input.is_action_just_released("right"):
		state = "r_idle"
		
	velocity.x = direction * speed
	
	if not is_on_floor():
		velocity.y -= gravity * _delta
		
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_force
	
	move_and_slide()
