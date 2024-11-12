extends CharacterBody3D

# Nodes
@onready var animation_player = $AnimationPlayer

# Scenes
@onready var player = get_node("/root/World/Spirit")

# Variables
var player_detected = false

func _process(delta: float) -> void:
	if player_detected:
		if position.y in range(player.position.y-2, player.position.y+0.5):
			animation_player.play("idle_straight")
		else:
			animation_player.play("idle_up")

func _on_detect_player_body_entered(body: Node3D) -> void:
	if body.name == "Spirit":
		player_detected = true 

func _on_detect_player_body_exited(body: Node3D) -> void:
	if body.name == "Spirit":
		player_detected = false
