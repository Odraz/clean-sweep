extends Camera2D

func _ready():
	set_global_position($"../Player".global_position)


func _process(delta: float):
	set_global_position(global_position.lerp($"../Player".global_position, delta))