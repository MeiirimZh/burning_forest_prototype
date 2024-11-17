extends Control

func _on_replay_btn_pressed() -> void:
	get_tree().change_scene_to_packed(Global.current_level)

func _on_quit_btn_pressed() -> void:
	get_tree().quit()
