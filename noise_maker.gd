extends Node2D

enum NoiseStat { ORIGIN, INTENSITY, ALPHA }

const START_ANGLE: float = 0
const END_ANGLE: float = 360
const SEGMENTS: int = 70
const WIDTH: int = 2
const COLOR: Color = Color(0.7, 0.7, 0.6, 0.5)
const ANTIALIASING: bool = false

var noises: Array = []

func _ready():
	SignalBus.noise_made.connect(_on_noise_made)


func _process(_delta: float):
	queue_redraw()


func _draw():
	var color = COLOR
	for noise in noises:
		noise[NoiseStat.ALPHA] = max(0, noise[NoiseStat.ALPHA] - 0.02)
		color.a = noise[NoiseStat.ALPHA]
		draw_arc(noise[NoiseStat.ORIGIN], noise[NoiseStat.INTENSITY], START_ANGLE, END_ANGLE, SEGMENTS, color, WIDTH, ANTIALIASING)

		if noise[NoiseStat.ALPHA] <= 0:
			noises.remove_at(noises.find(noise))


func _on_noise_made(origin: Vector2, intensity: float):
	var noise = {
		NoiseStat.ORIGIN: origin,
		NoiseStat.INTENSITY: intensity,
		NoiseStat.ALPHA: COLOR.a
	}
	noises.append(noise)
	