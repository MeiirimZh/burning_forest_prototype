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
@export var hp := 1
var player_detected := false
var can_attack := true
var direction := -1
var merc_damaged := false

# Functions
func spawn_projectile():
	var projectile_instance = projectile_scene.instantiate()
	var spawn_position
	
	if abs(position.y - player.position.y) > 1.3:
		projectile_instance.type = 'up'
	
	# Align the spawn position based on direction and attack type
	if direction == 1 and projectile_instance.type == "straight":
		spawn_position = self.global_position + Vector3(direction, 1.2, 0)
	elif direction == -1 and projectile_instance.type == "straight":
		spawn_position = self.global_position + Vector3(direction-0.4, 1.2, 0)
	elif direction == 1 and projectile_instance.type == "up":
		spawn_position = self.global_position + Vector3(direction, 1.2, 0)
	else:
		spawn_position = self.global_position + Vector3(direction, 1.4, 0)
	
	projectile_instance.direction = direction
	projectile_instance.position = spawn_position
	
	get_tree().current_scene.add_child(projectile_instance)

# Rotate the mesh and play an animation 
func rotate_and_play(angle, animation):
	mesh.rotation.y = angle
	animation_player.play(animation)

func _process(_delta: float) -> void:
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
		spawn_projectile()
		can_attack = false
		attack_cooldown_timer.start(attack_cooldown_duration)

func _on_detect_player_body_entered(body: Node3D) -> void:
	if body.name == "Spirit":
		player_detected = true 

func _on_detect_player_body_exited(body: Node3D) -> void:
	if body.name == "Spirit":
		player_detected = false

func _on_attack_cooldown_timer_timeout() -> void:
	can_attack = true

func _on_detect_damage_merc_damage_taken(dam: Variant) -> void:
	hp -= dam
	merc_damaged = true
	if hp <= 0:
		queue_free()
