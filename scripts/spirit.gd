extends CharacterBody3D

# Nodes
@onready var animation_player = $AnimationPlayer
@onready var mesh = $Armature

# Physics variables
@export var speed := 7.0
@export var jump_force := 12.0
@export var gravity := 30.0

# Variables
@export var state := "r_idle"
var is_jumping := false
var last_direction = "r"

# Rotate the mesh and play an animation 
func rotate_and_play(angle, animation):
	mesh.rotation.y = angle
	animation_player.play(animation)

func _physics_process(_delta) -> void:
	var direction = 0
	
	# Check the state and play the corresponding animation
	if state == "r_idle":
		rotate_and_play(0, "idle")
	elif state == "l_idle":
		rotate_and_play(85, "idle")
	elif state == "r_run" and not is_jumping:
		rotate_and_play(-92.5, "run")
	elif state == "l_run" and not is_jumping:
		rotate_and_play(92.5, "run")
	elif state == "front_jump":
		animation_player.play("jump_front")
	elif state == "front_fall":
		animation_player.play("fall_front")
	elif state == "side_jump":
		animation_player.play("jump_side")
	
	# Running
	if Input.is_action_pressed("left"):
		direction = -1
		state = "l_run"
		last_direction = "l"
	elif Input.is_action_pressed("right"):
		direction = 1
		state = "r_run"
		last_direction = "r"
	
	# Reset the state to idle after a movement
	if Input.is_action_just_released("left"):
		state = "l_idle"
	elif Input.is_action_just_released("right"):
		state = "r_idle"
		
	velocity.x = direction * speed
	
	if not is_on_floor():
		velocity.y -= gravity * _delta
		if velocity.y < 0 and is_jumping:
			state = "front_fall"
	else:
		if is_jumping:
			is_jumping = false
			if last_direction == "r":
				state = "r_idle"
			else:
				state = "l_idle"
		
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_force
		is_jumping = true
		if velocity.x == 0:
			state = "front_jump"
		else:
			state = "side_jump"
	
	move_and_slide()
