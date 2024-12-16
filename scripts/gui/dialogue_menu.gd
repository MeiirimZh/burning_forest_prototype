extends CanvasLayer

# Nodes
@onready var speech = $Control/MarginContainer/MarginContainer/HBoxContainer/VBoxContainer/Speech

# Variables
var in_progress := false
var row := 0

func _ready() -> void:
	hide()

func start_dialogue(key):
	show()
	in_progress = true

func _process(delta: float) -> void:
	if in_progress:
		if Input.is_action_just_pressed("jump"):
			pass
