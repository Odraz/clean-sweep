extends CharacterBody2D

signal hit(collider: Object)
signal player_died()
signal gun_changed(current_gun)
signal gun_shot(current_gun)
signal gun_started_reloading(current_gun)
signal gun_reloaded(current_gun)
signal grenade_thrown(grenade_count: int, grenades: int)

const GUN_ANIMATIONS = {
	GunStats.GunType.HANDGUN: "handgun",
	GunStats.GunType.SHOTGUN: "shotgun",
	GunStats.GunType.RIFLE: "rifle",
}

enum PlayerState {
	DEFAULT,
	RELOADING,
	THROWING_GRENADE,
	DEAD,
}

const GRENADE_COUNT: int = 3

@onready var current_gun: = $Guns/Handgun

var state: PlayerState = PlayerState.DEFAULT

var speed_walk: float = 150
var speed_run: float = 200
var speed_aim_modifier: float = 0.5
var grenades: int = GRENADE_COUNT

var screen_size

func _ready():
	screen_size = get_viewport_rect().size

func _physics_process(delta):
	if state == PlayerState.DEAD:
		return

	move(delta)

func _process(_delta):	
	if state == PlayerState.DEAD:
		return

	turn()

	var has_shot = Input.is_action_just_pressed("gun_shoot")

	if state == PlayerState.DEFAULT:
		$AnimationBody.play("idle_" + GUN_ANIMATIONS[current_gun.type])
	
		if Input.is_action_just_pressed("gun_reload") and current_gun.magazines > 0:
			reload()

		if Input.is_action_just_released("grenade_throw") and grenades > 0:
			init_throw_grenade()

		if has_shot:
			current_gun.shoot(get_global_mouse_position(), 500, $Crosshair.pos_x / 70 * PI / 20)
		
		handle_gun_selection()

	update_crosshair(has_shot)

	animate_legs()


func _on_gun_hit(collider: Object):
	hit.emit(collider)


func _on_hit(collider: Object) -> void:
	if collider == self:
		state = PlayerState.DEAD

		$AnimationBody.play("death")
		$AnimationLegs.hide()
		$CollisionShape2D.disabled = true
		$NavigationObstacle2D.avoidance_enabled = false
		$LightOccluder2D.hide()
		$Audio/AudioFootsteps.stop()
		$Audio/AudioDeath.play()
		$DeathTimer.start()


func _on_death_timer_timeout() -> void:
	player_died.emit()


func _on_gun_reloaded():
	if state == PlayerState.DEAD:
		return

	state = PlayerState.DEFAULT

	gun_reloaded.emit(current_gun)


func _on_gun_shot() -> void:
	gun_shot.emit(current_gun)


func _on_animation_body_animation_finished():
	if state == PlayerState.DEAD:
		return

	if $AnimationBody.animation  == "reload_" + GUN_ANIMATIONS[current_gun.type]:
		state = PlayerState.DEFAULT
	elif $AnimationBody.animation == "throw_grenade":
		state = PlayerState.DEFAULT
		throw_grenade()
	

func move(_delta: float):	
	var input_velocity = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var is_running = Input.is_action_pressed("move_fast")
	var is_aiming = Input.is_action_pressed("gun_aim")

	scale_footsteps_pitch(is_running)

	velocity = \
		input_velocity \
		* (speed_run if is_running else speed_walk) \
		* (speed_aim_modifier if is_aiming else 1.0)

	move_and_slide()
	

func turn():	
	look_at(get_global_mouse_position())


func update_crosshair(has_shot: bool):
	var new_crosshair_pos_x = calculate_crosshair_pos_x(has_shot)

	$Crosshair.set_pos_x(new_crosshair_pos_x, has_shot)


func scale_footsteps_pitch(is_running: bool):
	if is_running:
		$Audio/AudioFootsteps.pitch_scale = 1
	else:
		$Audio/AudioFootsteps.pitch_scale = 0.8


func calculate_crosshair_pos_x(has_shot: bool) -> float:
	return $Crosshair.CURSOR_DEFAULT_POS_X \
			- 10 * (GunStats.GUN_STATS[current_gun.type][GunStats.GunStat.PRECISION_HIP] - 1) \
			+ 20 * pow (velocity.length() / speed_run, 3) \
			- (5 * GunStats.GUN_STATS[current_gun.type][GunStats.GunStat.PRECISION_AIM] if Input.is_action_pressed("gun_aim") else 0.0) \
			+ (40 * GunStats.GUN_STATS[current_gun.type][GunStats.GunStat.RECOIL] if has_shot else 0.0)


func handle_gun_selection():
	if Input.is_action_just_pressed("gun_select_1"):
		current_gun = $Guns/Handgun
	elif Input.is_action_just_pressed("gun_select_2"):
		current_gun = $Guns/Shotgun
	elif Input.is_action_just_pressed("gun_select_3"):
		current_gun = $Guns/Rifle
	elif Input.is_action_just_pressed("gun_select_next"):
		current_gun = $Guns.get_child((current_gun.get_index() + 1) % $Guns.get_child_count())
	elif Input.is_action_just_pressed("gun_select_previous"):
		current_gun = $Guns.get_child((current_gun.get_index() - 1 + $Guns.get_child_count()) % $Guns.get_child_count())
	else:
		return
	
	gun_changed.emit(current_gun)


func reload():
	state = PlayerState.RELOADING

	current_gun.reload()

	gun_started_reloading.emit(current_gun)

	$AnimationBody.play("reload_" + GUN_ANIMATIONS[current_gun.type])


func init_throw_grenade():
	state = PlayerState.THROWING_GRENADE

	$AnimationBody.play("throw_grenade")


func throw_grenade():		
	var grenade_scene = load("res://grenade.tscn")
	var grenade = grenade_scene.instantiate()

	get_tree().current_scene.add_child(grenade)

	grenade.global_position = global_position + Vector2.RIGHT.rotated(rotation) * 30
	grenade.apply_impulse(Vector2.RIGHT.rotated(rotation) * 300, global_position)

	grenades -= 1

	grenade_thrown.emit(GRENADE_COUNT, grenades)


func animate_legs():
	if velocity.length() > 0:
		$AnimationLegs.speed_scale = 1.5 * velocity.length() / speed_run
		$AnimationLegs.play("move")

		if not $Audio/AudioFootsteps.is_playing():
			$Audio/AudioFootsteps.play()
	else:
		$AnimationLegs.play("idle")
		$Audio/AudioFootsteps.stop()