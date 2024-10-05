extends Marker2D

func _input(event: InputEvent):
	if $Area2D.get_overlapping_bodies().all(func(b): return b.name != "Player"):
		return

	# Clamp the rotation between 0 and 165 degrees
	if event.is_action_pressed("door_open"):
		rotation = clamp(rotation + 0.3, 0, deg_to_rad(165))
	elif event.is_action_pressed("door_close"):
		rotation = clamp(rotation - 0.3, 0, deg_to_rad(165))
