extends Camera2D

# Sets global position to player's position who is a sibling node
func _ready():
	set_global_position_clamped($"../Player".global_position)


# Clamp the camera to the player's position
func _process(delta: float):
	set_global_position_clamped(global_position.lerp($"../Player".global_position, delta))


func set_global_position_clamped(new_position: Vector2):
	set_global_position(new_position.clamp(Vector2(120, 120), Vector2(640, 400)))