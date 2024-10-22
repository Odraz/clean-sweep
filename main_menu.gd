extends CanvasLayer

func _ready():
	$SingleplayerButton.grab_focus()


func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("action_cancel"):
		quit_game()

	if event.is_action_pressed("action_submit"):
		var current = get_viewport().gui_get_focus_owner()

		current.emit_signal("pressed")


func _on_singleplayer_button_pressed():
	next("res://main_menu_singleplayer.tscn")


func _on_multiplayer_button_pressed():
	next("res://main_menu_multiplayer.tscn")


func _on_quit_button_pressed():
	quit_game()


func next(screen_name):
	get_tree().change_scene_to_file(screen_name)


func quit_game():
	get_tree().quit()
