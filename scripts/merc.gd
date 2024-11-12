extends CharacterBody3D

# Nodes
@onready var animation_player = $AnimationPlayer
@onready var mesh = $Armature
@onready var attack_cooldown_timer = $AttackCooldownTimer

# Scenes
@onready var player = get_node("/root/World/Spirit")
@export var projectile_scene : PackedScene = preload("res://scenes/enemy_projectile.tscn")

# Variables
@export var attack_cooldown_duration := 2.0
var player_detected := false
var can_attack := true
var direction := -1

# Functions
func spawn_projectile(delta, v_speed):
	var projectile_instance = projectile_scene.instantiate()
	var spawn_position
	if direction == 1:
		spawn_position = self.global_position + Vector3(direction, 1.2, 0)
	else:
		spawn_position = self.global_position + Vector3(direction-0.6, 1.2, 0)
	
	projectile_instance.direction = direction
	projectile_instance.position = spawn_position
	
	projectile_instance.move(delta, v_speed)
	
	get_tree().current_scene.add_child(projectile_instance)

# Rotate the mesh and play an animation 
func rotate_and_play(angle, animation):
	mesh.rotation.y = angle
	animation_player.play(animation)

func _process(delta: float) -> void:
	if player_detected:
		if abs(position.y - player.position.y) <= 1.3 and position.x >= player.position.x:
			rotate_and_play(0, "idle_straight")
			direction = -1
		elif abs(position.y - player.position.y) <= 1.3 and position.x < player.position.x:
			rotate_and_play(-160, "idle_straight")
			direction = 1
		else:
			animation_player.play("idle_up")
	
	if player_detected and can_attack:
		can_attack = false
		attack_cooldown_timer.start(attack_cooldown_duration)
		if abs(position.y - player.position.y) > 1.3:
			spawn_projectile(delta, 8.0)
		else:
			spawn_projectile(delta, 0)
		

func _on_detect_player_body_entered(body: Node3D) -> void:
	if body.name == "Spirit":
		player_detected = true 

func _on_detect_player_body_exited(body: Node3D) -> void:
	if body.name == "Spirit":
		player_detected = false

func _on_attack_cooldown_timer_timeout() -> void:
	can_attack = true
