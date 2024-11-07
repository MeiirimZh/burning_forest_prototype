extends CharacterBody3D

# Nodes
@onready var animation_player = $AnimationPlayer
@onready var mesh = $Armature
@onready var slide_timer = $SlideTimer

# Physics variables
@export var speed := 7.0
@export var jump_force := 12.0
@export var gravity := 30.0
@export var slide_duration := 0.5

# Variables
@export var state := "r_idle"
var is_jumping := false
var is_sliding := false
var last_direction = 1

# Rotate the mesh and play an animation 
func rotate_and_play(angle, animation):
	mesh.rotation.y = angle
	animation_player.play(animation)

# Set an idle animation based on a last direction
func set_idle():
	if last_direction == 1:
		state = "r_idle"
	else:
		state = "l_idle"

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
	elif state == "side_fall":
		animation_player.play("fall_side")
	elif state == "slide":
		animation_player.play("slide")
	
	# Running
	if Input.is_action_pressed("left"):
		direction = -1
		state = "l_run"
		last_direction = -1
	elif Input.is_action_pressed("right"):
		direction = 1
		state = "r_run"
		last_direction = 1
	
	# Reset the state to idle after a movement
	if velocity.x == 0 and is_on_floor():
		set_idle()
	
	if not is_on_floor():
		velocity.y -= gravity * _delta
		if velocity.y < 0 and velocity.x == 0 and is_jumping:
			state = "front_fall"
		if velocity.y < 0 and velocity.x != 0 and is_jumping:
			state = "side_fall"
	else:
		if is_jumping:
			is_jumping = false
			set_idle()
		
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_force
		is_jumping = true
		if velocity.x == 0:
			state = "front_jump"
		else:
			state = "side_jump"
			
	if Input.is_action_just_pressed("slide") and is_on_floor():
		is_sliding = true
		slide_timer.start(slide_duration)
		
	if is_sliding:
		if velocity.x == 0:
			state = "slide"
		velocity.x = last_direction * speed * 2
	else:
		velocity.x = direction * speed
	
	move_and_slide()

func _on_slide_timer_timeout() -> void:
	is_sliding = false
