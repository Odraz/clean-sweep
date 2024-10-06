extends CharacterBody2D

signal player_died()
signal gun_changed()
signal gun_shot()
signal gun_started_reloading()
signal gun_reloaded()
signal grenade_thrown()

enum PlayerState {
	DEFAULT,
	RELOADING,
	THROWING_GRENADE,
	DEAD,
}

const GUN_ANIMATIONS = {
	GunSettings.Type.HANDGUN: "handgun",
	GunSettings.Type.SHOTGUN: "shotgun",
	GunSettings.Type.RIFLE: "rifle",
}

const GRENADE_SCENE: Resource = preload("res://grenade.tscn")
const GRENADE_COUNT: int = 3
const GRENADE_ORIGIN_OFFSET: int = 30
const GRENADE_THROW_FORCE: int = 300

const SPEED_WALK: float = 150
const SPEED_RUN: float = 200
const SPEED_AIM_MODIFIER: float = 0.5
const FOOTSTEP_SPEED_MODIFIER: float = 1.5

var state: PlayerState = PlayerState.DEFAULT
var grenades: int = GRENADE_COUNT

@onready var screen_size: = get_viewport_rect().size
@onready var current_gun: = $Guns/Handgun


func _physics_process(delta):
	if is_dead():
		return

	move(delta)


func _process(_delta):	
	if is_dead():
		return

	look_at_mouse_position()

	if state == PlayerState.DEFAULT:
		$AnimationBody.play("idle_" + GUN_ANIMATIONS[current_gun.type])
	
	animate_legs()

	update_crosshair(false)


func _input(event):
	if is_dead():
		return
	
	var has_shot = event.is_action_pressed("gun_shoot")

	if state == PlayerState.DEFAULT:
		if event.is_action_pressed("gun_reload") and current_gun.magazines > 0:
			reload()

		if event.is_action_released("grenade_throw") and grenades > 0:
			init_throw_grenade()

		if has_shot:
			current_gun.shoot(get_global_mouse_position(), $Crosshair.pos_x / 70 * PI / 20)
		
		handle_gun_selection(event)

	update_crosshair(has_shot)


func _on_gun_hit(collider: Object):
	if collider.has_method("hit"):
		collider.hit()


func _on_death_timer_timeout() -> void:
	player_died.emit()


func _on_gun_reloaded():
	if is_dead():
		return

	set_state(PlayerState.DEFAULT)

	gun_reloaded.emit()


func _on_gun_shot() -> void:
	gun_shot.emit()


func _on_animation_body_animation_finished():
	if is_dead():
		return

	if $AnimationBody.animation  == "reload_" + GUN_ANIMATIONS[current_gun.type]:
		set_state(PlayerState.DEFAULT)
	elif $AnimationBody.animation == "throw_grenade":
		set_state(PlayerState.DEFAULT)
		throw_grenade()
	

func is_dead():
	return state == PlayerState.DEAD


func move(_delta: float):	
	var input_velocity = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var is_running = Input.is_action_pressed("move_fast")
	var is_aiming = Input.is_action_pressed("gun_aim")

	scale_footsteps_pitch(is_running)

	velocity = calculate_velocity(input_velocity, is_running, is_aiming)

	move_and_slide()


func scale_footsteps_pitch(is_running: bool):
	if is_running:
		$Audio/AudioFootsteps.pitch_scale = 1
	else:
		$Audio/AudioFootsteps.pitch_scale = 0.8


func calculate_velocity(input_velocity: Vector2, is_running: bool, is_aiming: bool):
	return input_velocity \
		* (SPEED_RUN if is_running else SPEED_WALK) \
		* (SPEED_AIM_MODIFIER if is_aiming else 1.0)


func look_at_mouse_position():	
	look_at(get_global_mouse_position())


func update_crosshair(has_shot: bool):
	var new_crosshair_pos_x = calculate_crosshair_pos_x(has_shot)

	$Crosshair.set_pos_x(new_crosshair_pos_x, has_shot)


func calculate_crosshair_pos_x(has_shot: bool):
	return $Crosshair.CURSOR_DEFAULT_POS_X \
			- 10 * (current_gun.precision_hip - 1) \
			+ 20 * pow (velocity.length() / SPEED_RUN, 3) \
			- (5 * current_gun.precision_aim if Input.is_action_pressed("gun_aim") else 0.0) \
			+ (40 * current_gun.recoil if has_shot else 0.0)


func handle_gun_selection(event):
	if event.is_action_pressed("gun_select_1"):
		current_gun = $Guns/Handgun
	elif event.is_action_pressed("gun_select_2"):
		current_gun = $Guns/Shotgun
	elif event.is_action_pressed("gun_select_3"):
		current_gun = $Guns/Rifle
	elif event.is_action_pressed("gun_select_next"):
		current_gun = $Guns.get_child((current_gun.get_index() + 1) % $Guns.get_child_count())
	elif event.is_action_pressed("gun_select_previous"):
		current_gun = $Guns.get_child((current_gun.get_index() - 1 + $Guns.get_child_count()) % $Guns.get_child_count())
	else:
		return
	
	gun_changed.emit()


func reload():
	set_state(PlayerState.RELOADING)

	current_gun.reload()

	gun_started_reloading.emit()

	$AnimationBody.play("reload_" + GUN_ANIMATIONS[current_gun.type])


func init_throw_grenade():
	set_state(PlayerState.THROWING_GRENADE)

	$AnimationBody.play("throw_grenade")


func throw_grenade():		
	var grenade = GRENADE_SCENE.instantiate()

	get_tree().current_scene.add_child(grenade)

	grenade.global_position = global_position + Vector2.RIGHT.rotated(rotation) * GRENADE_ORIGIN_OFFSET
	grenade.apply_impulse(Vector2.RIGHT.rotated(rotation) * GRENADE_THROW_FORCE, global_position)

	grenades -= 1

	grenade_thrown.emit()


func animate_legs():
	if velocity.length() > 0:
		$AnimationLegs.speed_scale = FOOTSTEP_SPEED_MODIFIER * velocity.length() / SPEED_RUN
		$AnimationLegs.play("move")

		if not $Audio/AudioFootsteps.is_playing():
			$Audio/AudioFootsteps.play()
	else:
		$AnimationLegs.play("idle")
		$Audio/AudioFootsteps.stop()


func set_state(new_state: PlayerState):
	if state == PlayerState.DEAD:
		push_warning("Player is dead, cannot change state")

	state = new_state


func hit():
	set_state(PlayerState.DEAD)

	$AnimationBody.play("death")
	$AnimationLegs.hide()
	$CollisionShape2D.disabled = true
	$NavigationObstacle2D.avoidance_enabled = false
	$LightOccluder2D.hide()
	$Audio/AudioFootsteps.stop()
	$Audio/AudioDeath.play()
	$DeathTimer.start()