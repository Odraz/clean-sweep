extends CanvasLayer

func _ready():
	$ShootingRangeButton.grab_focus()


func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("action_cancel"):
		back()

	if event.is_action_pressed("action_submit"):
		var current = get_viewport().gui_get_focus_owner()

		current.emit_signal("pressed")


func _on_shooting_range_button_pressed():
	start_game("res://level_shooting_range.tscn")


func _on_small_house_button_pressed():
	start_game("res://level_small_house.tscn")


func _on_back_button_pressed():
	back()


func start_game(level_name):
	get_tree().change_scene_to_file(level_name)


func back():
	get_tree().change_scene_to_file("res://main_menu.tscn")
