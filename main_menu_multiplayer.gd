extends MainMenu

func _ready():
	$BackButton.grab_focus()


func _back():
	back_to_intro()
	

func _on_back_button_pressed():
	back_to_intro()