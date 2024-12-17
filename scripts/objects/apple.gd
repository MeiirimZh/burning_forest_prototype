extends Area3D

# Nodes - Sounds
@onready var drain_energy = $Sounds/DrainEnergy

# Scenes
@onready var player = get_node("/root/World/Spirit")

# Variables
@export var mode := "heal"
var player_max_hp : int

func _ready() -> void:
	player_max_hp = player.hp

func _on_body_entered(body: Node3D) -> void:
	if body.name == "Spirit":
		if body.hp < player_max_hp and mode == "heal":
			$MeshInstance3D.visible = false
			drain_energy.play()
			body.hp += 1
			Global.player_healed = true
		elif mode == "collect":
			Global.score += 1
			
			queue_free()

func _on_drain_energy_finished() -> void:
	queue_free()
