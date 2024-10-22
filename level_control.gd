extends Node

func _input(event: InputEvent):
	if event.is_action_pressed("action_cancel"):
		quit()


func _on_player_player_died():
	quit()


func quit():
	get_tree().change_scene_to_file("res://main_menu_intro.tscn")
