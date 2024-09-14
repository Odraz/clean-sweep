extends Node2D

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _exit_tree():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _process(_delta: float):
	global_position = get_global_mouse_position()
	global_rotation = 0

func fire(speed):
	# For every child node which is a pivot
	for pivot in get_children():
		pivot.get_node("Line2D").get_node("AnimationPlayer").speed_scale = speed
		pivot.get_node("Line2D").get_node("AnimationPlayer").stop()
		pivot.get_node("Line2D").get_node("AnimationPlayer").play("move")
