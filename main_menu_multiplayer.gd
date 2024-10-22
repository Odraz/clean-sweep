extends CanvasLayer

func _ready():
	$BackButton.grab_focus()


func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("action_cancel"):
		back()

	if event.is_action_pressed("action_submit"):
		var current = get_viewport().gui_get_focus_owner()

		current.emit_signal("pressed")


func _on_back_button_pressed():
	back()


func back():
	get_tree().change_scene_to_file("res://main_menu.tscn")