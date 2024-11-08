extends CharacterBody3D

# Nodes
@onready var animation_player = $AnimationPlayer
@onready var mesh = $Armature
@onready var slide_timer = $SlideTimer
@onready var slide_cooldown_timer = $SlideCooldownTimer
@onready var collision_shape = $CollisionShape3D

# Physics variables
@export var speed := 7.0
@export var jump_force := 12.0
@export var gravity := 30.0
@export var slide_duration := 0.5
@export var slide_cooldown_duration := 2.0

# Variables
@export var state := "r_idle"
var is_jumping := false
var is_sliding := false
var last_direction := 1
var can_slide := true

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
		if last_direction == 1:
			rotate_and_play(0, "fall_front")
		else:
			rotate_and_play(85, "fall_front")
	elif state == "side_jump":
		if last_direction == 1:
			rotate_and_play(-92.5, "jump_side")
		else:
			rotate_and_play(92.5, "jump_side")
	elif state == "side_fall":
		if last_direction == 1:
			rotate_and_play(-92.5, "fall_side")
		else:
			rotate_and_play(92.5, "fall_side")
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
			
	if Input.is_action_just_pressed("slide") and is_on_floor() and can_slide:
		is_sliding = true
		can_slide = false
		slide_timer.start(slide_duration)
		slide_cooldown_timer.start(slide_cooldown_duration)
		
	if is_sliding:
		if velocity.x == 0:
			state = "slide"
			collision_shape.transform.origin.y = 0.5
			collision_shape.shape.height = 1
			velocity.x = last_direction * speed * 2
	else:
		velocity.x = direction * speed
	
	move_and_slide()

func _on_slide_timer_timeout() -> void:
	is_sliding = false
	collision_shape.transform.origin.y = 0.85
	collision_shape.shape.height = 1.7

func _on_slide_cooldown_timer_timeout() -> void:
	can_slide = true
