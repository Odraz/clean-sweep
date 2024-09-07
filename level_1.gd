extends Node

signal game_over()

func _on_player_player_died():
	game_over.emit()
