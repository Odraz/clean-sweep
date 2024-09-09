extends Node

var current_level

func _process(_delta: float):
	if Input.is_action_just_pressed("action_cancel") and $MainMenu.visible:
		quit()

func _on_main_menu_start_game():
	current_level = preload("res://level_1.tscn").instantiate()
	get_tree().root.add_child(current_level)

	current_level.connect("game_over", show_main_menu)

	$MainMenu.hide()

func _on_main_menu_quit_game():
	quit()

func show_main_menu():
	current_level.queue_free()
	
	$MainMenu.show()

func quit():
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)

	get_tree().quit()