extends Camera2D

@export var player: Node2D

func _ready():
	if !player:
		push_warning("Player not set in camera_player.gd")
		return

	set_global_position(calculate_camera_position())


func _process(delta: float):
	set_global_position(global_position.lerp(calculate_camera_position(), delta))


func calculate_camera_position():
	var player_position = player.global_position if player else Vector2.ZERO
	var mouse_position = get_global_mouse_position()
	
	return player_position.lerp(mouse_position, 0.3)