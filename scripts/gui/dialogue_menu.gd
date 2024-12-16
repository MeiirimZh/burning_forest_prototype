extends CanvasLayer

# Nodes
@onready var speaker = $Control/MarginContainer/MarginContainer/HBoxContainer/VBoxContainer/Speaker
@onready var speech = $Control/MarginContainer/MarginContainer/HBoxContainer/VBoxContainer/Speech
@onready var portrait_texture_rect = $Control/Portrait

# Portraits
@onready var spirit_anxiety = preload("res://images/portraits/SpiritAnxiety.png")
@onready var spirit_shock = preload("res://images/portraits/SpiritShock.png")
var portraits

# Variables
var current_key : String
var in_progress := false
var i := 0

func _ready() -> void:
	hide()
	portraits = {"spirit_anxiety": spirit_anxiety, "spirit_shock": spirit_shock}
	
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
		portrait_texture_rect.texture = portraits[Global.dialogues[current_key]["icons"][i]]
		if Input.is_action_just_pressed("enter"):
			if i < Global.dialogues[current_key]["text"].size() - 1:
				next_line()
			else:
				finish()
