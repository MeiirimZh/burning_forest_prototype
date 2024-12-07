extends Area3D

# Variables
@export var mode := "heal"

func _on_body_entered(body: Node3D) -> void:
	if body.name == "Spirit":
		if body.hp < 5 and mode == "heal":
			body.hp += 1
			Global.player_healed = true
			
			queue_free()
		elif mode == "collect":
			Global.score += 1
			
			queue_free()
