extends CanvasLayer

func _ready() -> void:
	$AnimationPlayer.play("RESET")

func resume():
	get_tree().paused = false
	$AnimationPlayer.play_backwards("blur")

func pause():
	get_tree().paused = true
	$AnimationPlayer.play("blur")

func testEsc():
	if Input.is_action_just_pressed("esc"):
		if get_tree().paused == false:
			pause()
		else:
			resume()

func _process(_delta: float) -> void:
	testEsc()


func _on_resume_btn_pressed() -> void:
	resume()


func _on_restart_btn_pressed() -> void:
	resume()
	get_tree().reload_current_scene()

func _on_quit_btn_pressed() -> void:
	get_tree().quit()
