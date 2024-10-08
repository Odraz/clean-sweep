extends Node

const COLLISION_OFFSET: int = 40

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


## Initialize the bullet with a start and end position in global space and set the collision shape to a segment between the two points.
## Small offset is applied to the start position to destroy any object that is between the gun's muzzle and the shooter.
func init(start: Vector2, end: Vector2):
	$Fire.points = [start, end]
	$Smoke.points = [start, end]

	start -= (end - start).normalized() * COLLISION_OFFSET

	$CollisionShape2D.shape = SegmentShape2D.new()
	$CollisionShape2D.shape.a = start
	$CollisionShape2D.shape.b = end

