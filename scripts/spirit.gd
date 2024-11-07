extends CharacterBody3D

@export var speed := 7.0
@export var jump_force := 10.0
@export var gravity := 30.0

func _physics_process(_delta) -> void:
	var direction = 0
	
	if Input.is_action_pressed("left"):
		direction = -1
	elif Input.is_action_pressed("right"):
		direction = 1
		
	velocity.x = direction * speed
	
	if not is_on_floor():
		velocity.y -= gravity * _delta
		
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_force
	
	move_and_slide()
