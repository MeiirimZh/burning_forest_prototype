extends CanvasLayer

# Nodes
@onready var hearts = [$Control/Hearts/Heart1, $Control/Hearts/Heart2, $Control/Hearts/Heart3,
$Control/Hearts/Heart4, $Control/Hearts/Heart5]
@onready var ghost_progress_bar = $Control/GhostProgressBar

# Scenes
@onready var player = get_node("/root/World/Spirit")

# Shaders
var darken_img = load("res://shaders/darken_image.gdshader")

# ShaderMaterials
var darken_img_sm : ShaderMaterial = ShaderMaterial.new()

func _ready() -> void:
	darken_img_sm.shader = darken_img

func _process(_delta: float) -> void:
	if Global.player_damaged == true:
		hearts[player.hp].material = darken_img_sm  # Darken the heart by the hp index
		
		Global.player_damaged = false
		
	if Global.player_healed == true:
		hearts[player.hp-1].material = null # Recover the heart by the hp index
		
		Global.player_healed = false

func _on_spirit_ghost_activated(duration: Variant) -> void:
	var tween = create_tween()
	tween.tween_property(ghost_progress_bar, "value", 100, duration)
	tween.play()

func _on_spirit_ghost_recover(duration: Variant) -> void:
	var tween = create_tween()
	tween.tween_property(ghost_progress_bar, "value", 0, duration)
	tween.play()
