class_name MainMenu

extends CanvasLayer

func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("action_cancel"):
		_back()

	if event.is_action_pressed("action_submit"):
		var current = get_viewport().gui_get_focus_owner()

		current.emit_signal("pressed")


func _back():
	pass


func next(screen_name):
	get_tree().change_scene_to_file(screen_name)


func back_to_intro():
	get_tree().change_scene_to_file("res://main_menu_intro.tscn")
	

func quit_game():
	get_tree().quit()