extends Area3D

# Variables
@export var key : String

func _on_body_entered(body: Node3D) -> void:
	if body.name == "Spirit":
		if body.has_node("DialogueMenu"):
			body.invert_functionality()
			var dialogue_menu = body.get_node("DialogueMenu")
			dialogue_menu.start_dialogue(key)
		else:
			print("No such node!")
