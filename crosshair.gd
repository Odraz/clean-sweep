extends Node2D

var pos_x: float = 15

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)


func _process(delta: float):

	global_position = get_global_mouse_position()
	global_rotation = 0

	for pivot in get_children():
		pivot.get_node("Line2D").position.x = lerp(pivot.get_node("Line2D").position.x, pos_x, delta * 12)


func _exit_tree():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func fire(speed):
	for pivot in get_children():
		pivot.get_node("Line2D").get_node("AnimationPlayer").speed_scale = speed
		pivot.get_node("Line2D").get_node("AnimationPlayer").stop()
		pivot.get_node("Line2D").get_node("AnimationPlayer").play("move")


func stop_fire():
	for pivot in get_children():
		if pivot.get_node("Line2D").get_node("AnimationPlayer").is_playing():
			pivot.get_node("Line2D").get_node("AnimationPlayer").stop()
