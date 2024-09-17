extends CanvasLayer

signal start_game
signal quit_game

func _on_quit_button_pressed():
	quit_game.emit()


func _on_start_button_pressed():
	start_game.emit()	
