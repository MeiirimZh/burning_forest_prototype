extends CanvasLayer

# Nodes
@onready var hearts = [$Control/Hearts/Heart1, $Control/Hearts/Heart2, $Control/Hearts/Heart3,
$Control/Hearts/Heart4, $Control/Hearts/Heart5]

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
