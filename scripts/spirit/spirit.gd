extends CharacterBody3D

# Nodes
@onready var animation_player = $AnimationPlayer
@onready var armature = $Armature
@onready var mesh = $Armature/Skeleton3D/mesh

# Nodes - Timers
@onready var slide_timer = $SlideTimer
@onready var slide_cooldown_timer = $SlideCooldownTimer
@onready var attack_cooldown_timer = $AttackCooldownTimer
@onready var damage_timer = $DamageTimer
@onready var ghost_timer = $GhostTimer
@onready var ghost_cooldown_timer = $GhostCooldownTimer

# Nodes - CollisionShapes
@onready var collision_shape = $CollisionShape3D
@onready var detect_dmg_collision_shape = $DetectDamage/CollisionShape3D

# Nodes - Particles
@onready var leaves_particles = $Leaves
@onready var blood_particles = $Blood
@onready var ghost_particles = $GhostParticles

# Scenes
@export var projectile_scene : PackedScene = preload("res://scenes/projectiles/spirit_projectile.tscn")
@export var game_over_scene : PackedScene = preload("res://levels/gameover.tscn")

# Physics variables
@export var speed := 7.0
@export var jump_force := 12.0
@export var gravity := 30.0

# Variables
@export var state := "r_idle"
@export var hp := 5
var last_direction := 1

# Variables - Cooldowns
@export var slide_duration := 0.5
@export var slide_cooldown_duration := 2.0
@export var attack_cooldown_duration := 0.3
@export var damage_cooldown_duration := 1.0
@export var ghost_duration := 10.0
@onready var ghost_cooldown_duration := 45.0

# Signals
signal ghost_activated(duration)
signal ghost_recover(duration)

# Flags
var is_jumping := false
var is_sliding := false
var is_attacking := false
var can_take_damage := true
var can_ghost := false

# Shaders
var transparency = load("res://shaders/transparency.gdshader")

# ShaderMaterials
var transparency_sm : ShaderMaterial = ShaderMaterial.new()

# Rotate the armature play an animation 
func rotate_and_play(angle, animation):
	armature.rotation.y = angle
	animation_player.play(animation)

# Set an idle animation based on a last direction
func set_idle():
	if last_direction == 1:
		state = "r_idle"
	else:
		state = "l_idle"

func spawn_projectile():
	var projectile_instance = projectile_scene.instantiate()
	var spawn_position = self.global_position + Vector3(last_direction, 1.2, 0)
	
	projectile_instance.direction = last_direction
	projectile_instance.position = spawn_position
	
	get_tree().current_scene.add_child(projectile_instance)
	
func _ready() -> void:
	Global.player_mode = "normal"
	transparency_sm.shader = transparency
	ghost_cooldown_timer.start(ghost_cooldown_duration)
	emit_signal("ghost_recover", ghost_cooldown_duration)

func _physics_process(_delta) -> void:
	var direction = 0

	# Attack
	if Input.is_action_just_pressed("attack") and not is_sliding and attack_cooldown_timer.time_left == 0 and hp > 0:
		spawn_projectile()
		is_attacking = true

		leaves_particles.restart()
		leaves_particles.emitting = true
		
		attack_cooldown_timer.start(attack_cooldown_duration)
	
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
		if last_direction == 1:
			rotate_and_play(0, "slide")
		else:
			rotate_and_play(85, "slide")
	elif state == "idle_attack":
		if last_direction == 1:
			rotate_and_play(0, "attack_idle")
		else:
			rotate_and_play(85, "attack_idle")
	elif state == "run_attack":
		if last_direction == 1:
			rotate_and_play(-92.5, "attack_run")
		else:
			rotate_and_play(92.5, "attack_run")
	elif state == "jump_attack":
		if last_direction == 1:
			rotate_and_play(0, "attack_jump")
		else:
			rotate_and_play(85, "attack_jump")
	elif state == "death":
		if last_direction == 1:
			rotate_and_play(0, "death")
		else:
			rotate_and_play(85, "death")
	
	# Running
	if Input.is_action_pressed("left") and not is_sliding and hp > 0:
		direction = -1
		state = "l_run"
		leaves_particles.position = Vector3(-0.65, 1.05, 0)
		last_direction = -1
		
	elif Input.is_action_pressed("right") and not is_sliding and hp > 0:
		direction = 1
		state = "r_run"
		leaves_particles.position = Vector3(0.65, 1.05, 0)
		last_direction = 1
	
	# Reset the state to idle after a movement
	if velocity.x == 0 and is_on_floor() and not is_attacking and hp > 0:
		set_idle()
		
	if is_attacking:
		if velocity.x == 0 and not is_jumping:
			state = "idle_attack"
		elif is_jumping:
			state = "jump_attack"
		else:
			state = "run_attack"
	
	if not is_on_floor():
		velocity.y -= gravity * _delta
		if velocity.y < 0 and velocity.x == 0 and not is_attacking:
			state = "front_fall"
		if velocity.y < 0 and velocity.x != 0 and not is_attacking:
			state = "side_fall"
	else:
		if is_jumping:
			is_jumping = false
			set_idle()
		
	if Input.is_action_just_pressed("jump") and is_on_floor() and hp > 0:
		velocity.y = jump_force
		is_jumping = true
		if velocity.x == 0 and not is_attacking:
			state = "front_jump"
		elif velocity.x != 0 and not is_attacking:
			state = "side_jump"
			
	if Input.is_action_just_pressed("slide") and is_on_floor() and slide_cooldown_timer.time_left == 0 \
	and not is_attacking and hp > 0:
		is_sliding = true
		slide_timer.start(slide_duration)
		slide_cooldown_timer.start(slide_cooldown_duration)
		
	if Input.is_action_just_pressed("ghost") and can_ghost:
		Global.player_mode = "ghost"
		emit_signal("ghost_activated", ghost_duration)
		mesh.material_override = transparency_sm
		collision_layer = (1 << 0)
		collision_mask = (1 << 0)
		
		ghost_particles.emitting = true
		detect_dmg_collision_shape.disabled = true
		can_ghost = false
		ghost_timer.start(ghost_duration)
		
	if is_sliding:
		if is_jumping:
			state = "side_jump"
		else:
			state = "slide"
		# Change collision shape to go through smaller spaces
		collision_shape.transform.origin.y = 0.5
		collision_shape.shape.height = 1
		# Change collision shape to avoid attack
		if is_instance_valid(detect_dmg_collision_shape):
			detect_dmg_collision_shape.position = Vector3(0, 0.5, 0)
			detect_dmg_collision_shape.shape.size = Vector3(1, 1, 1)
	
	if is_sliding:
		velocity.x = last_direction * speed * 2
	elif Global.player_mode == "ghost":
		velocity.x = direction * speed * 1.5
	else:
		velocity.x = direction * speed

	move_and_slide()

func _on_slide_timer_timeout() -> void:
	is_sliding = false
	collision_shape.transform.origin.y = 0.85
	collision_shape.shape.height = 1.7
	
	if is_instance_valid(detect_dmg_collision_shape):
		detect_dmg_collision_shape.position = Vector3(0, 0.85, 0)
		detect_dmg_collision_shape.shape.size = Vector3(1, 1.7, 1)

func _on_attack_cooldown_timer_timeout() -> void:
	is_attacking = false

func _on_damage_timer_timeout() -> void:
	if hp > 0:
		can_take_damage = true

# Take damage
func _on_detect_damage_spirit_damage_taken(dam: Variant) -> void:
	if can_take_damage:
		hp -= dam
		Global.player_damaged = true
		
		# Temporary invulnerability
		can_take_damage = false
		damage_timer.start(damage_cooldown_duration)
		
		blood_particles.restart()
		blood_particles.emitting = true
		
		if hp <= 0:
			can_take_damage = false
			
			state = "death"
			
			# Make enemy projectiles go through the player
			detect_dmg_collision_shape.queue_free()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "death":
		get_tree().change_scene_to_packed(game_over_scene)

func _on_ghost_cooldown_timer_timeout() -> void:
	can_ghost = true

func _on_ghost_timer_timeout() -> void:
	collision_layer = (1 << 0) | (1 << 2)
	collision_mask = (1 << 0) | (1 << 2)
	
	Global.player_mode = "normal"
	emit_signal("ghost_recover", ghost_cooldown_duration)
	ghost_particles.emitting = false
	mesh.material_override = null
	detect_dmg_collision_shape.disabled = false
	
	ghost_cooldown_timer.start(ghost_cooldown_duration)
