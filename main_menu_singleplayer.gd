extends MainMenu

func _ready():
	$ShootingRangeButton.grab_focus()


func _back():
	back_to_intro()
	

func _on_shooting_range_button_pressed():
	next("res://level_shooting_range.tscn")


func _on_small_house_button_pressed():
	next("res://level_small_house.tscn")


func _on_back_button_pressed():
	back_to_intro()
