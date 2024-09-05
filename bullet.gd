extends Node

@export var smoke_fade_out_speed: float = 1.8

func _ready() -> void:
	$Fire.visible = true

func _process(delta: float) -> void:
	if $Smoke.visible:
		$Smoke.default_color.a -= smoke_fade_out_speed * delta

func _on_fire_timer_timeout() -> void:
	$Fire.visible = false
	$Smoke.visible = true

	$SmokeTimer.start()

func _on_smoke_timer_timeout() -> void:
	queue_free()

func init(start: Vector2, end: Vector2) -> void:
	$Fire.points = [start, end]
	$Smoke.points = [start, end]
