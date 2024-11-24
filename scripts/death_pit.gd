extends Area3D

# Nodes
@onready var color_rect = $DeathFade/ColorRect
@onready var animation_player = $DeathFade/AnimationPlayer

# Scenes
@export var game_over_scene : PackedScene = preload("res://levels/gameover.tscn")

func _ready() -> void:
	color_rect.visible = false

func _on_body_entered(body: Node3D) -> void:
	if body.name == "Spirit":
		color_rect.visible = true
		animation_player.play("fade_to_black")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_to_black":
		get_tree().change_scene_to_packed(game_over_scene)
