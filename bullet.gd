extends Node

@export var smoke_fade_out_speed: float = 1.8

func _ready():
	$Fire.visible = true


func _process(delta: float):
	if $Smoke.visible:
		$Smoke.default_color.a -= smoke_fade_out_speed * delta


func _on_fire_timer_timeout():
	$Fire.visible = false
	$Smoke.visible = true

	$SmokeTimer.start()


func _on_smoke_timer_timeout():
	queue_free()


func init(start: Vector2, end: Vector2):
	$Fire.points = [start, end]
	$Smoke.points = [start, end]
