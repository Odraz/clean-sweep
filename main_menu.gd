extends CanvasLayer

func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("action_submit"):
		start_game()
	elif event.is_action_pressed("action_cancel"):
		quit_game()


func _on_start_button_pressed():
	start_game()


func _on_quit_button_pressed():
	quit_game()


func start_game():
	get_tree().change_scene_to_file("res://level_1.tscn")


func quit_game():
	get_tree().quit()
