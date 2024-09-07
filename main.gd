extends Node

var current_level

func _on_main_menu_start_game():
	current_level = preload("res://level_1.tscn").instantiate()
	get_tree().root.add_child(current_level)

	current_level.connect("game_over", show_main_menu)

	$MainMenu.hide()

func _on_main_menu_quit_game():
	get_tree().quit()

func show_main_menu():
	current_level.queue_free()
	$MainMenu.show()