extends CharacterBody3D

# Nodes
@onready var animation_player = $AnimationPlayer
@onready var armature = $Armature
@onready var mesh = $Armature/Skeleton3D/mesh

# Nodes - Timers
@onready var slide_timer = $Timers/SlideTimer
@onready var slide_cooldown_timer = $Timers/SlideCooldownTimer
@onready var attack_cooldown_timer = $Timers/AttackCooldownTimer
@onready var damage_timer = $Timers/DamageTimer
@onready var ghost_timer = $Timers/GhostTimer
@onready var ghost_cooldown_timer = $Timers/GhostCooldownTimer
@onready var footstep_timer = $Timers/FootstepTimer

# Nodes - CollisionShapes
@onready var collision_shape = $CollisionShape3D
@onready var detect_dmg_collision_shape = $DetectDamage/CollisionShape3D

# Nodes - Particles
@onready var leaves_particles = $Particles/Leaves
@onready var blood_particles = $Particles/Blood
@onready var ghost_particles = $Particles/GhostParticles

# Nodes - Sounds
@onready var footstep = $Sounds/Footstep
@onready var rapid_wind = $Sounds/RapidWind
@onready var rapid_wind_2 = $Sounds/RapidWind2
@onready var burn = $Sounds/Burn
@onready var leaves_crunch = $Sounds/LeavesCrunch
@onready var fire = $Sounds/Fire

# Scenes
@export var projectile_scene : PackedScene = preload("res://scenes/projectiles/spirit_projectile.tscn")
@export var game_over_scene : PackedScene = preload("res://levels/gameover.tscn")

# Physics variables
@export var speed := 7.0
@export var jump_force := 12.0
@export var gravity := 30.0

# Variables
@export var state := "idle"
@export var hp := 5
var last_direction := 1
var state_animation_angles = {"idle": [0, 85], "run": [-92.5, 92.5], "jump_front": [0, 85],
"fall_front": [0, 85], "jump_side": [-92.5, 92.5], "fall_side": [-92.5, 92.5],
"slide": [0, 85], "attack_idle": [0, 85], "attack_run": [-92.5, 92.5],
"attack_jump": [0, 85], "death": [0, 85]}

# Variables - Cooldowns
@export var slide_duration := 0.5
@export var slide_cooldown_duration := 2.0
@export var attack_cooldown_duration := 0.3
@export var damage_cooldown_duration := 1.0
@export var ghost_duration := 10.0
@export var ghost_cooldown_duration := 45.0

# Signals
signal ghost_activated(duration)
signal ghost_recover(duration)

# Flags
var is_jumping := false
var is_sliding := false
var is_attacking := false
var can_move := true
var can_jump := true
var can_attack := true
var can_slide := true
var can_ghost := true

# Shaders
var transparency = load("res://shaders/transparency.gdshader")

# ShaderMaterials
var transparency_sm : ShaderMaterial = ShaderMaterial.new()

# Rotate the armature play an animation 
func play_animation_based_on_state(direction, angle_1, angle_2, animation):
	if direction == 1:
		armature.rotation.y = angle_1
		animation_player.play(animation)
	else:
		armature.rotation.y = angle_2
		animation_player.play(animation)

func spawn_projectile():
	var projectile_instance = projectile_scene.instantiate()
	var spawn_position = self.global_position + Vector3(last_direction, 1.2, 0)
	
	projectile_instance.direction = last_direction
	projectile_instance.position = spawn_position
	
	get_tree().current_scene.add_child(projectile_instance)
	
func die():
	state = "death"
	
	# Make enemy projectiles go through the player
	detect_dmg_collision_shape.queue_free()

func invert_functionality():
	can_move = !can_move
	can_jump = !can_jump
	can_attack = !can_attack
	can_slide = !can_slide
	can_ghost = !can_ghost
	
func play_footstep_audio():
	footstep.pitch_scale = randf_range(.9, 1.1)
	footstep.play()

func _ready() -> void:
	Global.player_mode = "normal"
	transparency_sm.shader = transparency
	ghost_cooldown_timer.start(ghost_cooldown_duration)
	emit_signal("ghost_recover", ghost_cooldown_duration)

func _physics_process(_delta) -> void:
	var direction = 0

	# Attack
	if Input.is_action_just_pressed("attack") and not is_sliding and attack_cooldown_timer.time_left == 0 and hp > 0 and can_attack:
		spawn_projectile()
		is_attacking = true

		leaves_particles.restart()
		leaves_particles.emitting = true
		
		leaves_crunch.pitch_scale = randf_range(0.8, 1.2)
		leaves_crunch.play()
		
		attack_cooldown_timer.start(attack_cooldown_duration)
	
	# Check the state and play the corresponding animation
	play_animation_based_on_state(last_direction, state_animation_angles[state][0], state_animation_angles[state][1], state)
	
	# Running
	if Input.is_action_pressed("left") and not is_sliding and hp > 0 and can_move:
		direction = -1
		last_direction = -1
		leaves_particles.position = Vector3(-0.65, 1.05, 0)
		if is_on_floor():
			state = "run"
		
	elif Input.is_action_pressed("right") and not is_sliding and hp > 0 and can_move:
		direction = 1
		last_direction = 1
		leaves_particles.position = Vector3(0.65, 1.05, 0)
		if is_on_floor():
			state = "run"
	
	# Reset the state to idle after a movement
	if velocity.x == 0 and is_on_floor() and not is_attacking and hp > 0:
		state = "idle"
		footstep.stop()
		
	if velocity.length() > 1 and not is_jumping and not is_sliding and is_on_floor():
		if footstep_timer.time_left <= 0:
			play_footstep_audio()
			footstep_timer.start(0.4)
		
	if is_attacking:
		if velocity.x == 0 and not is_jumping:
			state = "attack_idle"
		elif is_jumping:
			state = "attack_jump"
		else:
			state = "attack_run"
	
	if not is_on_floor():
		velocity.y -= gravity * _delta
		if velocity.y < 0 and velocity.x == 0 and not is_attacking:
			state = "fall_front"
		if velocity.y < 0 and velocity.x != 0 and not is_attacking:
			state = "fall_side"
	else:
		if is_jumping:
			is_jumping = false
			state = "idle"
		
	if Input.is_action_just_pressed("jump") and is_on_floor() and hp > 0 and can_jump:
		velocity.y = jump_force
		is_jumping = true
		if velocity.x == 0 and not is_attacking:
			state = "jump_front"
		elif velocity.x != 0 and not is_attacking:
			state = "jump_side"
		rapid_wind_2.pitch_scale = randf_range(0.8, 1.2)
		rapid_wind_2.play()
	
	if Input.is_action_just_pressed("slide") and is_on_floor() and slide_cooldown_timer.time_left == 0 \
	and not is_attacking and hp > 0 and can_slide:
		is_sliding = true
		slide_timer.start(slide_duration)
		slide_cooldown_timer.start(slide_cooldown_duration)
		rapid_wind.pitch_scale = randf_range(1.2, 1.4)
		rapid_wind.play()
		
	if Input.is_action_just_pressed("ghost") and ghost_cooldown_timer.time_left == 0 and can_ghost:
		Global.player_mode = "ghost"
		emit_signal("ghost_activated", ghost_duration)
		mesh.material_override = transparency_sm
		collision_layer = (1 << 0)
		collision_mask = (1 << 0)
		burn.play()
		
		ghost_particles.emitting = true
		detect_dmg_collision_shape.disabled = true
		ghost_timer.start(ghost_duration)
		
	if is_sliding:
		if is_jumping:
			state = "jump_side"
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

# Take damage
func _on_detect_damage_spirit_damage_taken(dam: Variant) -> void:
	if hp > 0:
		if damage_timer.time_left == 0:
			hp -= dam
			Global.player_damaged = true
		
			# Temporary invulnerability
			damage_timer.start(damage_cooldown_duration)
		
			blood_particles.restart()
			blood_particles.emitting = true

			if hp <= 0:
				fire.pitch_scale = 0.6
				die()
				
			fire.play()
	else:
		die()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "death":
		get_tree().change_scene_to_packed(game_over_scene)

func _on_ghost_timer_timeout() -> void:
	collision_layer = (1 << 0) | (1 << 2)
	collision_mask = (1 << 0) | (1 << 2)
	
	Global.player_mode = "normal"
	emit_signal("ghost_recover", ghost_cooldown_duration)
	ghost_particles.emitting = false
	mesh.material_override = null
	detect_dmg_collision_shape.disabled = false
	burn.play()
	
	ghost_cooldown_timer.start(ghost_cooldown_duration)
