extends Node

signal game_over()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("action_cancel"):
		quit()
func _on_player_player_died():
	quit()

func quit():
	game_over.emit()
