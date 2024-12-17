extends Node

# Nodes
@export var ambient : AudioStreamPlayer
@export var player : CharacterBody3D

func _ready() -> void:
	ambient.play()
	
func _process(delta: float) -> void:
	if Global.player_damaged:
		if player.hp == 0:
			ambient.pitch_scale = Global.low_pitch_scale
