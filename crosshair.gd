extends Node2D

const CURSOR_DEFAULT_POS_X = 10

var pos_x: float = CURSOR_DEFAULT_POS_X

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)


func _process(delta: float):
	global_position = get_global_mouse_position()
	global_rotation = 0

	for pivot in get_children():
		pivot.get_node("Line2D").position.x = lerp(pivot.get_node("Line2D").position.x, pos_x, delta * 12)


func _exit_tree():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func set_pos_x(new_pos_x: float, should_move_instantly: bool):
	if should_move_instantly:
		for pivot in get_children():
			pivot.get_node("Line2D").position.x = new_pos_x
	
	pos_x = new_pos_x