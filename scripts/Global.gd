extends Node

# Scenes
var current_level : PackedScene = preload("res://levels/world.tscn")

# Variables
var score := 0
var player_damaged := false
var player_healed := false
var player_mode := "normal"

# Dialogues
var dialogues = {"intro": {"speakers": ["Spirit"], "icons": [], "text": ["Humans can control fire?! That is... impossible!"]}}
