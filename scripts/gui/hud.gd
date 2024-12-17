extends CanvasLayer

# Nodes
@onready var hearts = [$Control/Hearts/Heart1, $Control/Hearts/Heart2, $Control/Hearts/Heart3,
$Control/Hearts/Heart4, $Control/Hearts/Heart5]
@onready var ghost_progress_bar = $Control/GhostProgressBar

# Scenes
@onready var player = get_node("/root/World/Spirit")

# Tweens
var tween_active
var tween_recover

# Variables
var ghost_progress_bar_start_value := 0.0
var ghost_progress_bar_end_value := 100.0
var duration_active
var duration_recover
var elapsed_time_active := 0.0
var elapsed_time_recover := 0.0

# Flags
var is_paused := false

# Shaders
var darken_img = load("res://shaders/darken_image.gdshader")

# ShaderMaterials
var darken_img_sm : ShaderMaterial = ShaderMaterial.new()

func _ready() -> void:
	darken_img_sm.shader = darken_img
	duration_active = player.ghost_duration
	duration_recover = player.ghost_cooldown_duration

func start_tween_active():
	tween_active = create_tween()
	tween_active.tween_property(ghost_progress_bar, "value", ghost_progress_bar_end_value, duration_active)

func start_tween_recover():
	tween_recover = create_tween()
	tween_recover.tween_property(ghost_progress_bar, "value", ghost_progress_bar_start_value, duration_recover)

func pause_tweens():
	if tween_active and tween_active.is_running():
		elapsed_time_active = tween_active.get_total_elapsed_time()
		tween_active.kill()
	elif tween_active and not tween_active.is_running():
		elapsed_time_active = 0.0

	if tween_recover and tween_recover.is_running():
		elapsed_time_recover = tween_recover.get_total_elapsed_time()
		tween_recover.kill()
	elif tween_recover and not tween_recover.is_running():
		elapsed_time_recover = 0.0
	
	is_paused = true

func resume_tweens():
	if is_paused:
		if elapsed_time_active >= 0.0 or tween_active == null:
			var remaining_time_active = duration_active - elapsed_time_active
			tween_active = create_tween()
			tween_active.tween_property(ghost_progress_bar, "value", ghost_progress_bar_end_value, remaining_time_active)
			
		if elapsed_time_recover >= 0.0 or tween_recover == null:
			var remaining_time_recover = duration_recover - elapsed_time_recover
			tween_recover = create_tween()
			tween_recover.tween_property(ghost_progress_bar, "value", ghost_progress_bar_start_value, remaining_time_recover)
			
		is_paused = false

func _process(_delta: float) -> void:
	if Global.player_damaged == true:
		hearts[player.hp].material = darken_img_sm  # Darken the heart by the hp index
		
		Global.player_damaged = false
		
	if Global.player_healed == true:
		hearts[player.hp-1].material = null # Recover the heart by the hp index
		
		Global.player_healed = false

func _on_spirit_ghost_activated(_duration: Variant) -> void:
	start_tween_active()

func _on_spirit_ghost_recover(_duration: Variant) -> void:
	start_tween_recover()
