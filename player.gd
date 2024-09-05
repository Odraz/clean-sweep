extends CharacterBody2D

#signal when player hit something
signal hit (collider: CollisionObject2D)

@export var speed_walk: float = 150
@export var speed_run: float = 300

var screen_size

func _ready():
	screen_size = get_viewport_rect().size

func _physics_process(delta):
	move_player(delta)

	if Input.is_action_just_pressed("shoot_gun"):
		shoot_ray()

func move_player(_delta: float):
	var _velocity = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	var is_running = Input.is_action_pressed("move_fast")

	velocity = _velocity * (speed_run if is_running else speed_walk)

	move_and_slide()

	look_at(get_global_mouse_position())

	if velocity.length() > 0:
		$AnimatedSprite2D.play("move")
	else:
		$AnimatedSprite2D.play("idle")

func shoot_ray():
	var space_state = get_world_2d().direct_space_state

	var query = PhysicsRayQueryParameters2D.create(position, get_shoot_ray_end_position())
	query.collide_with_areas = true

	print("Shooting ray from: ", position, " to: ", get_shoot_ray_end_position())

	var result = space_state.intersect_ray(query)

	print("Result: ", result)

	if result:
		print("Hit at point: ", result.position)
		
		hit.emit(result.collider)

	spawn_bullet(result)

func spawn_bullet(result: Dictionary):
	var bullet_scene = load("res://bullet.tscn")
	var bullet = bullet_scene.instantiate()

	var start_position = position + (get_global_mouse_position() - position).normalized() * 20
	var end_position = result.position if result else get_shoot_ray_end_position()

	bullet.init(start_position, end_position)

	add_child(bullet)

func get_shoot_ray_end_position():
	return position + (get_global_mouse_position() - position).normalized() * 500