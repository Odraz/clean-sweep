extends Sprite2D

const BLAST_FADE_OUT_SPEED: float = 6

func _ready():
	SignalBus.noise_made.emit(global_position, 450)

func _process(delta: float):
	if modulate.a > 0:
		modulate.a -= BLAST_FADE_OUT_SPEED * delta


func _on_timer_timeout() -> void:
	queue_free()
