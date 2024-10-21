extends CharacterBody2D

signal player_died()
signal gun_changed()
signal gun_shot()
signal gun_started_reloading()
signal gun_reloaded()
signal grenade_thrown()

enum PlayerState {
	DEFAULT,
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
const GRENADE_THROW_FORCE_MIN: int = 50
const GRENADE_THROW_FORCE_MAX: int = 500
const GRENADE_CHARGE_TIME: float = 1.0

const SPEED_WALK: float = 150
const SPEED_RUN: float = 200
const SPEED_AIM_MODIFIER: float = 0.5
const FOOTSTEP_SPEED_MODIFIER: float = 1.5

const CROSSHAIR_SPEED: float = 600

var state: PlayerState = PlayerState.DEFAULT
var grenades: int = GRENADE_COUNT
var grenade_throw_force: int = GRENADE_THROW_FORCE_MIN

@onready var screen_size: = get_viewport_rect().size
@onready var current_gun: = $Guns/Handgun


func _physics_process(delta):
	if is_dead():
		return

	move(delta)


func _process(delta):	
	if is_dead():
		return

	look_at_crosshair()

	animate_legs()

	make_noise()

	move_crosshair(delta)

	update_crosshair(false)

	if is_charging_grenade():
		grenade_throw_force = min(grenade_throw_force + GRENADE_THROW_FORCE_MAX / GRENADE_CHARGE_TIME * delta, GRENADE_THROW_FORCE_MAX)

	current_gun.get_node("Target").global_position = $Crosshair.global_position


func _unhandled_input(event):
	if is_dead():
		return
	
	var has_shot = event.is_action_pressed("gun_shoot")

	if is_idle():
		if event.is_action_pressed("gun_reload") and current_gun.magazines > 0:
			reload()
		
		if event.is_action_pressed("grenade_throw") and grenades > 0:
			charge_grenade()

		if has_shot:
			current_gun.shoot($Crosshair.pos_x / 70 * PI / 20)
		
		handle_gun_selection(event)
	elif is_charging_grenade():
		if event.is_action_released("grenade_throw"):
			init_throw_grenade()

	update_crosshair(has_shot)


func _on_death_timer_timeout() -> void:
	player_died.emit()


func _on_gun_reloaded():
	if is_dead():
		return

	set_idle()

	gun_reloaded.emit()


func _on_gun_shot() -> void:
	SignalBus.noise_made.emit(global_position, 350)
	gun_shot.emit()


func _on_animation_body_animation_finished():
	if is_dead():
		return

	if $AnimationBody.animation == "throw_grenade":
		set_idle()
		throw_grenade()
	

func is_dead():
	return state == PlayerState.DEAD


func is_idle():
	return $AnimationBody.animation.begins_with("idle")


func is_charging_grenade():
	return $AnimationBody.animation == "charge_grenade"


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


func look_at_crosshair():	
	look_at($Crosshair.global_position)


func move_crosshair(delta: float):
	var crosshair_velocity = Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")

	get_viewport().warp_mouse(get_viewport().get_mouse_position() + crosshair_velocity * CROSSHAIR_SPEED * delta)


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
	
	set_idle()
	
	gun_changed.emit()


func reload():
	current_gun.reload()

	gun_started_reloading.emit()

	$AnimationBody.play("reload_" + GUN_ANIMATIONS[current_gun.type])


func charge_grenade():
	$AnimationBody.play("charge_grenade")


func init_throw_grenade():
	$AnimationBody.play("throw_grenade")


func throw_grenade():		
	var grenade = GRENADE_SCENE.instantiate()

	get_tree().current_scene.add_child(grenade)

	grenade.global_position = global_position + Vector2.RIGHT.rotated(rotation) * GRENADE_ORIGIN_OFFSET
	grenade.apply_impulse(Vector2.RIGHT.rotated(rotation) * grenade_throw_force, global_position)

	grenades -= 1
	grenade_throw_force = GRENADE_THROW_FORCE_MIN

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


func make_noise():
	if velocity.length() > 0 and $StepNoiseTimer.is_stopped():
		$StepNoiseTimer.start()
		_on_step_noise_timer_timeout()
	elif velocity.length() == 0 and not $StepNoiseTimer.is_stopped():
		$StepNoiseTimer.stop()
	
	if velocity.length() > SPEED_WALK:
		$StepNoiseTimer.wait_time = 0.5
	elif is_same(velocity.length(), SPEED_WALK):
		$StepNoiseTimer.wait_time = 1


func set_idle():
	$AnimationBody.play("idle_" + GUN_ANIMATIONS[current_gun.type])


func set_state(new_state: PlayerState):
	if state == PlayerState.DEAD:
		push_warning("Player is dead, cannot change state")

	state = new_state


func hit():
	set_state(PlayerState.DEAD)

	$AnimationLegs.hide()
	$AnimationBody.play("death")
	$Audio/AudioDeath.play()
	
	$CollisionShape2D.disabled = true
	$NavigationObstacle2D.avoidance_enabled = false
	
	$LightFieldOfView.hide()
	$Audio/AudioFootsteps.stop()
	$StepNoiseTimer.stop()
	
	$DeathTimer.start()


func _on_step_noise_timer_timeout():
	var noise

	if velocity.length() > SPEED_WALK:
		noise = 250 
	elif is_same(velocity.length(), SPEED_WALK):
		noise = 150
	else:
		noise = 0

	if noise > 0:
		SignalBus.noise_made.emit(global_position, noise)
