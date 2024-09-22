extends Node2D

signal hit(collider: Object)

@export var type: GunStats.GunType = GunStats.GunType.HANDGUN

@onready var magazine_size: int = GunStats.GUN_STATS[type][GunStats.GunStat.MAGAZINE_SIZE]
@onready var ammo: int = magazine_size

var end_position: Vector2

func _ready():
	$ReloadTimer.wait_time = GunStats.GUN_STATS[type][GunStats.GunStat.RELOAD_TIME]

	print("Gun:", type)
	print("Magazine size:", magazine_size)

func shoot(start_position: Vector2, direction: Vector2, gun_range: float, dispersion: float):
	if not $ReloadTimer.is_stopped():
		return

	if ammo <= 0:
		$AudioEmpty.play()

		return
	
	ammo -= 1

	var space_state = get_world_2d().direct_space_state

	end_position = get_shoot_ray_end_position(start_position, direction, gun_range)

	var angle = randf_range(-dispersion / 2, dispersion / 2)

	var diff = end_position - start_position
	end_position = diff.rotated(angle) + start_position

	var query = PhysicsRayQueryParameters2D.create(start_position, end_position)
	query.collide_with_areas = true

	var result = space_state.intersect_ray(query)

	if result and result.has("collider"):
		hit.emit(result.collider)

	spawn_bullet(result, start_position, direction)

	play_audio()


func spawn_bullet(result: Dictionary, start_position: Vector2, direction: Vector2):
	var bullet_scene = load("res://bullet.tscn")
	var bullet = bullet_scene.instantiate()

	var bullet_start_position = start_position + (direction - start_position).normalized() * 30
	var bullet_end_position = result.position if result else end_position

	bullet.init(bullet_start_position, bullet_end_position)

	add_child(bullet)


func get_shoot_ray_end_position(start_position: Vector2, direction: Vector2, gun_range: float) -> Vector2:
	return start_position + (direction - start_position).normalized() * gun_range
	

func play_audio():
	$AudioFire.pitch_scale = randf_range(0.9, 1.1)
	$AudioFire.play()


func reload():
	if $ReloadTimer.is_stopped():
		$ReloadTimer.start()


func _on_reload_timer_timeout():
	ammo = magazine_size

	$ReloadTimer.stop()
