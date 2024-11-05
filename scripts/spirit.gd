extends CharacterBody3D

@export var speed := 7.0

func _physics_process(_delta) -> void:
	var direction = 0
	
	if Input.is_action_pressed("left"):
		direction = -1
	elif Input.is_action_pressed("right"):
		direction = 1
		
	velocity.x = direction * speed
	
	move_and_slide()
