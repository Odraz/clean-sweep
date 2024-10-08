extends Node2D

signal hit(collider: Object)
signal shot()
signal reloaded()

const BULLET_OFFSET: int = 10

@export var type: GunSettings.Type = GunSettings.Type.HANDGUN

var dispersion: float
var end_position: Vector2

var burst_shot_index: int = 0

@onready var precision_hip: float = GunSettings.STATS[type][GunSettings.Stat.PRECISION_HIP]
@onready var precision_aim: float = GunSettings.STATS[type][GunSettings.Stat.PRECISION_AIM]
@onready var gun_range: float = GunSettings.STATS[type][GunSettings.Stat.RANGE] * 1300
@onready var recoil: float = GunSettings.STATS[type][GunSettings.Stat.RECOIL]
@onready var magazine_size: int = GunSettings.STATS[type][GunSettings.Stat.MAGAZINE_SIZE]
@onready var magazine_count: int = GunSettings.STATS[type][GunSettings.Stat.MAGAZINE_COUNT]
@onready var ammo: int = magazine_size
@onready var magazines: int = magazine_count
@onready var single_shot_bullet_count: int = GunSettings.STATS[type][GunSettings.Stat.SINGLE_SHOT_BULLET_COUNT]
@onready var burst_shot_count: int = GunSettings.STATS[type][GunSettings.Stat.BURST_SHOT_COUNT]
@onready var muzzle_distance: float = position.distance_to($Muzzle.position)

@onready var particle_emitter: Resource = preload("res://particle_emitter_bullet_impact.tscn")
@onready var bullet_scene: Resource = preload("res://bullet.tscn")

func _ready():
	$ReloadTimer.wait_time = GunSettings.STATS[type][GunSettings.Stat.RELOAD_TIME]

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


func shoot(_dispersion: float):
	if not $ReloadTimer.is_stopped() or not $BurstTimer.is_stopped():
		return

	if ammo <= 0:
		$AudioEmpty.play()
		return
	
	ammo -= 1

	dispersion = _dispersion

	for i in range(single_shot_bullet_count):
		shoot_once()

	if burst_shot_count > 1:
		$BurstTimer.start()

	play_audio()


func shoot_once():
	var space_state = get_world_2d().direct_space_state

	var start_position = global_position
	end_position = get_shoot_ray_end_position(start_position)
	var diff = end_position - start_position

	var angle = randf_range(-dispersion / 2, dispersion / 2)
	end_position = diff.rotated(angle) + start_position

	var query = PhysicsRayQueryParameters2D.create(start_position, end_position)
	query.collision_mask = 1
	query.collide_with_areas = true

	var result = space_state.intersect_ray(query)

	if result and result.has("collider"):
		hit.emit(result.collider)

		spawn_impact_particles(result)
	else:
		result = {}

	spawn_bullet(result)

	play_fire_animation()

	shot.emit()


func spawn_bullet(result: Dictionary):
	var bullet_end_position = result.position if result else end_position

	if global_position.distance_to(bullet_end_position) < muzzle_distance:
		return

	var bullet = bullet_scene.instantiate()

	var muzzle_position = $Muzzle.global_position

	var bullet_start_position = muzzle_position + ($Target.global_position - muzzle_position).normalized() * BULLET_OFFSET

	bullet.init(bullet_start_position, bullet_end_position)

	get_tree().current_scene.add_child(bullet)


func get_shoot_ray_end_position(start_position: Vector2) -> Vector2:
	return start_position + ($Target.global_position - start_position).normalized() * gun_range
	

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

	get_tree().current_scene.add_child(impact_particles)

	impact_particles.emitting = true


func play_fire_animation():
	$Muzzle.get_node("AnimatedSprite2D").play("fire_" + GunSettings.Type.keys()[type].to_lower())
	$Muzzle.get_node("AnimatedSprite2D").play("default")
