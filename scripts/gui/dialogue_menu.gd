extends CanvasLayer

# Nodes
@onready var speaker = $Control/MarginContainer/MarginContainer/HBoxContainer/VBoxContainer/Speaker
@onready var speech = $Control/MarginContainer/MarginContainer/HBoxContainer/VBoxContainer/Speech

# Variables
var current_key : String
var in_progress := false
var i := 0

func _ready() -> void:
	hide()
	
func next_line():
	i += 1

func finish():
	in_progress = false
	i = 0
	hide()
	get_parent().invert_functionality()

func start_dialogue(key):
	current_key = key
	show()
	in_progress = true

func _process(delta: float) -> void:
	if in_progress:
		speaker.text = Global.dialogues[current_key]["speakers"][i]
		speech.text = Global.dialogues[current_key]["text"][i]
		if Input.is_action_just_pressed("enter"):
			if i < Global.dialogues[current_key]["text"].size() - 1:
				next_line()
			else:
				finish()
