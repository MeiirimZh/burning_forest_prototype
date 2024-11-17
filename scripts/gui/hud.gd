extends CanvasLayer

# Nodes
@onready var hearts = [$Control/Hearts/Heart1, $Control/Hearts/Heart2, $Control/Hearts/Heart3,
$Control/Hearts/Heart4, $Control/Hearts/Heart5]

# Shaders
var darken_img = load("res://shaders/darken_image.gdshader")

func _ready() -> void:
	var darken_img_sm : ShaderMaterial = ShaderMaterial.new()
	darken_img_sm.shader = darken_img
