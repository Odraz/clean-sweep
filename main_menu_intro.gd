extends MainMenu

func _ready():
	$SingleplayerButton.grab_focus()


func _back():
	get_tree().quit()


func _on_singleplayer_button_pressed():
	next("res://main_menu_singleplayer.tscn")


func _on_multiplayer_button_pressed():
	next("res://main_menu_multiplayer.tscn")


func _on_quit_button_pressed():
	_back()