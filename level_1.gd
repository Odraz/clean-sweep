extends Node

func _process(_delta: float):
	if Input.is_action_just_pressed("action_cancel"):
		quit()


func _on_player_player_died():
	quit()


func quit():
	get_tree().change_scene_to_file("res://main_menu_intro.tscn")
