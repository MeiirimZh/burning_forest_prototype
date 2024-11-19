extends Sprite3D

# Nodes
@onready var hboxcontainer = $SubViewport/MarginContainer/HBoxContainer
@onready var parent = get_parent()

# Scenes
@export var skull_icon = preload("res://scenes/gui/skull_icon.tscn")

# Shaders
var darken_img = load("res://shaders/darken_image.gdshader")

# ShaderMaterials
var darken_img_sm : ShaderMaterial = ShaderMaterial.new()

# Variables
var skulls = []

func _ready() -> void:
	darken_img_sm.shader = darken_img
	
	for i in range(parent.hp):
		var skull_icon_instance = skull_icon.instantiate()
		skulls.append(skull_icon_instance)
		
		hboxcontainer.add_child(skull_icon_instance)

func _process(_delta: float) -> void:
	if parent.merc_damaged:
		skulls[parent.hp].material = darken_img_sm
		parent.merc_damaged = false
