extends CanvasLayer

# Nodes
@onready var speaker = $Control/MarginContainer/MarginContainer/HBoxContainer/VBoxContainer/Speaker
@onready var speech = $Control/MarginContainer/MarginContainer/HBoxContainer/VBoxContainer/Speech
@onready var portrait_texture_rect = $Control/Portrait
@onready var flower = $Control/Flower

# Portraits
@onready var spirit_anxiety = preload("res://images/portraits/SpiritAnxiety.png")
@onready var spirit_shock = preload("res://images/portraits/SpiritShock.png")
var portraits

# Tweens
var tween

# Flowers
@onready var living_flower = preload("res://images/icons/Flower.png")
@onready var dead_flower = preload("res://images/icons/DeadFlower.png")

# Variables
var current_key : String
var in_progress := false
var i := 0
var good_characters = ["Spirit"]

func _ready() -> void:
	hide()
	portraits = {"spirit_anxiety": spirit_anxiety, "spirit_shock": spirit_shock}

func tween_text(label):
	label.visible_ratio = 0.0
	tween = create_tween()
	tween.tween_property(label, "visible_ratio", 1.0, 2.0)
	
func restart_tween_text(label):
	tween.kill()
	label.visible_ratio = 1.0

func next_line():
	i += 1
	tween_text(speech)

func finish():
	in_progress = false
	i = 0
	hide()
	get_parent().invert_functionality()
	get_parent().ghost_cooldown_timer.set_paused(false)
	var hud = get_parent().get_node("HUD")
	hud.resume_tweens()

func start_dialogue(key):
	current_key = key
	get_parent().ghost_cooldown_timer.set_paused(true)
	var hud = get_parent().get_node("HUD")
	hud.pause_tweens()
	show()
	tween_text(speech)
	in_progress = true

func _process(_delta: float) -> void:
	if in_progress:
		# Set text
		speaker.text = Global.dialogues[current_key]["speakers"][i]
		speech.text = Global.dialogues[current_key]["text"][i]
		# Set images
		portrait_texture_rect.texture = portraits[Global.dialogues[current_key]["icons"][i]]
		if Global.dialogues[current_key]["speakers"][i] in good_characters:
			flower.texture = living_flower
		else:
			flower.texture = dead_flower
		
		if Input.is_action_just_pressed("enter"):
			if i < Global.dialogues[current_key]["text"].size() - 1:
				if speech.visible_ratio == 1:
					next_line()
				else:
					restart_tween_text(speech)
			else:
				if speech.visible_ratio == 1:
					finish()
				else:
					restart_tween_text(speech)
