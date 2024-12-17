extends Node

# Scenes
var current_level : PackedScene = preload("res://levels/world.tscn")

# Variables
var score := 0
var player_damaged := false
var player_healed := false
var player_mode := "normal"
var low_pitch_scale := 0.6

# Dialogues
var dialogues = {"intro": {"speakers": ["Spirit", "Spirit"],
					"icons": ["spirit_shock", "spirit_anxiety"], 
					"text": ["Humans can control fire?! That is... impossible!", "Okay...Remember what Willow taught you! Be brave!"]}}
