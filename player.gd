extends CharacterBody2D

signal hit(collider: Object)
signal player_died()

const GUN_ANIMATIONS = {
	GunStats.GunType.HANDGUN: "handgun",
	GunStats.GunType.SHOTGUN: "shotgun",
	GunStats.GunType.RIFLE: "rifle",
}

@onready var current_gun: = $Guns/Handgun

var speed_walk: float = 150
var speed_run: float = 200
var speec_aim_modifier: float = 0.5

var screen_size


func _ready():
	screen_size = get_viewport_rect().size

func _physics_process(delta):
	if not is_visible_in_tree():
		return

	move(delta)

func _process(_delta):	
	if not is_visible_in_tree():
		return

	turn()

	var has_shot = Input.is_action_just_pressed("gun_shoot")

	if has_shot:
		current_gun.shoot(position, get_global_mouse_position(), 500, $Crosshair.pos_x / 70 * PI / 20)
	
	var new_crosshair_pos_x = calculate_crosshair_pos_x(has_shot)

	$Crosshair.set_pos_x(new_crosshair_pos_x, has_shot)

	if velocity.length() > 0:
		$AnimatedSprite2D.play("move_" + GUN_ANIMATIONS[current_gun.type])

		if not $Audio/AudioFootsteps.is_playing():
			$Audio/AudioFootsteps.play()
	else:
		$AnimatedSprite2D.play("idle_" + GUN_ANIMATIONS[current_gun.type])
		$Audio/AudioFootsteps.stop()

	handle_gun_selection()

	if Input.is_action_just_pressed("gun_reload"):
		current_gun.reload()


func _on_gun_hit(collider: Object):
	hit.emit(collider)


func _on_mob_hit(collider: Object) -> void:
	if collider == self:
		hide()	
		$CollisionShape2D.disabled = true
		$Audio/AudioFootsteps.stop()
		$Audio/AudioDeath.play()
		$DeathTimer.start()


func _on_death_timer_timeout() -> void:
	player_died.emit()


func move(_delta: float):	
	var input_velocity = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var is_running = Input.is_action_pressed("move_fast")
	var is_aiming = Input.is_action_pressed("gun_aim")

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

