extends CharacterBody2D

signal hit(collider: Object)
signal player_died()

var speed_walk: float = 150
var speed_run: float = 200
var speec_aim_modifier: float = 0.5

var screen_size

func _ready():
	screen_size = get_viewport_rect().size

func _physics_process(delta):
	move(delta)

func _process(_delta):	
	turn()

	var has_shot = Input.is_action_just_pressed("shoot_gun")

	var new_crosshair_pos_x = calculate_crosshair_pos_x(has_shot)

	$Crosshair.set_pos_x(new_crosshair_pos_x, has_shot)

	if has_shot:
		$Gun.shoot(position, get_global_mouse_position(), 500, $Crosshair.pos_x / 70 * PI / 22)
	
	if velocity.length() > 0:
		$AnimatedSprite2D.play("move")

		if not $Audio/AudioFootsteps.is_playing():
			$Audio/AudioFootsteps.play()
	else:
		$AnimatedSprite2D.play("idle")
		$Audio/AudioFootsteps.stop()


func _on_gun_hit(collider: Object):
	hit.emit(collider)


func _on_mob_hit(collider: Object) -> void:
	if collider == self:
		hide()
		position = Vector2(0, 0)
		$Audio/AudioDeath.play()
		$DeathTimer.start()


func _on_death_timer_timeout() -> void:
	player_died.emit()


func move(_delta: float):	
	var input_velocity = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var is_running = Input.is_action_pressed("move_fast")
	var is_aiming = Input.is_action_pressed("aim_gun")

	scale_footsteps_pitch(is_running)

	velocity = \
		input_velocity \
		* (speed_run if is_running else speed_walk) \
		* (speec_aim_modifier if is_aiming else 1.0)

	move_and_slide()
	

func turn():	
	look_at(get_global_mouse_position())


func scale_footsteps_pitch(is_running: bool):
	if is_running:
		$Audio/AudioFootsteps.pitch_scale = 1
	else:
		$Audio/AudioFootsteps.pitch_scale = 0.8


func calculate_crosshair_pos_x(has_shot: bool) -> float:
	return $Crosshair.CURSOR_DEFAULT_POS_X \
			- 10 * (GunStats.GUN_STATS[$Gun.type][GunStats.GunStat.PRECISION_HIP] - 1) \
			+ 20 * pow (velocity.length() / speed_run, 3) \
			- (5 * GunStats.GUN_STATS[$Gun.type][GunStats.GunStat.PRECISION_AIM] if Input.is_action_pressed("aim_gun") else 0.0) \
			+ (40 * GunStats.GUN_STATS[$Gun.type][GunStats.GunStat.RECOIL] if has_shot else 0.0)
