extends Node2D

signal hit(collider: Object)
signal shot()
signal reloaded()

@export var type: GunStats.GunType = GunStats.GunType.HANDGUN

@onready var magazine_size: int = GunStats.GUN_STATS[type][GunStats.GunStat.MAGAZINE_SIZE]
@onready var magazine_count: int = GunStats.GUN_STATS[type][GunStats.GunStat.MAGAZINE_COUNT]
@onready var ammo: int = magazine_size
@onready var magazines: int = magazine_count
@onready var single_shot_bullet_count: int = GunStats.GUN_STATS[type][GunStats.GunStat.SINGLE_SHOT_BULLET_COUNT]
@onready var burst_shot_count: int = GunStats.GUN_STATS[type][GunStats.GunStat.BURST_SHOT_COUNT]

@onready var particle_emitter: Resource = load("res://particle_emitter_bullet_impact.tscn")

var direction: Vector2
var gun_range: float
var dispersion: float
var end_position: Vector2

var burst_shot_index: int = 0

func _ready():
	$ReloadTimer.wait_time = GunStats.GUN_STATS[type][GunStats.GunStat.RELOAD_TIME]

func _on_reload_timer_timeout():
	if magazine_count <= 0:
		return

	ammo = magazine_size
	magazines -= 1

	$ReloadTimer.stop()
	$AudioReload.stop()

	reloaded.emit()

func _on_burst_timer_timeout():
	if burst_shot_index < burst_shot_count - 1:
		burst_shot_index += 1
		ammo -= 1

		shoot_once()
	else:
		$BurstTimer.stop()

		burst_shot_index = 0


func shoot(_direction: Vector2, _gun_range: float, _dispersion: float):
	if not $ReloadTimer.is_stopped() or not $BurstTimer.is_stopped():
		return

	if ammo <= 0:
		$AudioEmpty.play()

		return
	
	ammo -= 1

	direction = _direction
	gun_range = _gun_range
	dispersion = _dispersion

	for i in range(single_shot_bullet_count):
		shoot_once()

	if burst_shot_count > 1:
		$BurstTimer.start()

	play_audio()


func shoot_once():
	var space_state = get_world_2d().direct_space_state

	# Get the start position of the ray which is the gun's global position.
	var start_position = global_position
	end_position = get_shoot_ray_end_position(start_position)
	var diff = end_position - start_position

	var angle = randf_range(-dispersion / 2, dispersion / 2)
	end_position = diff.rotated(angle) + start_position

	var query = PhysicsRayQueryParameters2D.create(start_position, end_position)
	query.collide_with_areas = true

	var result = space_state.intersect_ray(query)

	if result and result.has("collider"):
		hit.emit(result.collider)

		spawn_impact_particles(result)

	spawn_bullet(start_position, result)

	shot.emit()

func spawn_bullet(start_position: Vector2, result: Dictionary):
	var bullet_scene = load("res://bullet.tscn")
	var bullet = bullet_scene.instantiate()

	var bullet_start_position = start_position + (direction - start_position).normalized() * 30
	var bullet_end_position = result.position if result else end_position

	bullet.init(bullet_start_position, bullet_end_position)

	add_child(bullet)


func get_shoot_ray_end_position(start_position: Vector2) -> Vector2:
	return start_position + (direction - start_position).normalized() * gun_range
	

func play_audio():
	$AudioFire.pitch_scale = randf_range(0.9, 1.1)
	$AudioFire.play()


func reload():
	if $ReloadTimer.is_stopped():
		$ReloadTimer.start()
		$AudioReload.play()


func spawn_impact_particles(result: Dictionary):
	var impact_particles = particle_emitter.instantiate()

	impact_particles.global_position = result.position

	if result.collider.is_in_group("characters"):
		impact_particles.color = Color(1, 0, 0)

	get_tree().get_root().add_child(impact_particles)

	impact_particles.emitting = true