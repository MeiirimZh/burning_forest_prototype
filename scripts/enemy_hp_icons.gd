extends Sprite3D

# Nodes
@onready var hboxcontainer = $SubViewport/MarginContainer/HBoxContainer
@onready var parent = get_parent()

# Scenes
@export var skull_icon = preload("res://scenes/gui/skull_icon.tscn")

func _ready() -> void:
	for i in range(parent.hp):
		var skull_icon_instance = skull_icon.instantiate()
		
		hboxcontainer.add_child(skull_icon_instance)
