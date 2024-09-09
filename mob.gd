extends CharacterBody2D

enum State { patrolling, watching, chasing }

signal hit(collider: Object)

@export var movement_speed: float = 200.0

@export var movement_target_positions: Array[Marker2D] = []

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var player: Node2D = get_parent().get_node("Player")

var current_movement_target_index: int = 0

var state: State = State.patrolling

func _ready():
	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	navigation_agent.path_desired_distance = 4.0
	navigation_agent.target_desired_distance = 4.0

	set_physics_process(false)
	
	# Make sure to not await during _ready.
	call_deferred("actor_setup")

func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame
	set_physics_process(true)
	
	# Now that the navigation map is no longer empty, set the movement target.
	set_movement_target(movement_target_positions[current_movement_target_index].global_position)

func set_movement_target(movement_target: Vector2):
	navigation_agent.target_position = movement_target

func _physics_process(_delta):
	if is_player_in_light_of_sight():
		rotation = global_position.direction_to(player.global_position).angle()

		if state == State.patrolling or state == State.chasing:		
			$TriggerTimer.start()

		state = State.watching

		return
	elif state == State.watching:
		set_movement_target(player.global_position)

		state = State.chasing
	else:
		state = State.patrolling

	$TriggerTimer.stop()

	if navigation_agent.is_navigation_finished():
		set_waypoint_randomly()

		set_movement_target(movement_target_positions[current_movement_target_index].global_position)

	var next_path_position: Vector2 = navigation_agent.get_next_path_position()

	velocity = global_position.direction_to(next_path_position)

	# Face the direction of the next path position.
	if velocity.length_squared() > 0:
		rotation = velocity.angle()

	_on_navigation_agent_2d_velocity_computed(velocity)

func set_waypoint_randomly():
	var random_index = randi() % movement_target_positions.size()

	if random_index == current_movement_target_index:
		current_movement_target_index = (random_index + 1) % movement_target_positions.size()
	else:
		current_movement_target_index = random_index

func is_player_in_light_of_sight() -> bool:
	var direction_to_player = position.direction_to(player.position)
	var front_facing_vector = transform.x.normalized()

	if direction_to_player.dot(front_facing_vector) < 0.5 or position.distance_to(player.position) > 380:
		return false

	var space_state = get_world_2d().direct_space_state

	var query = PhysicsRayQueryParameters2D.create(position, player.position)
	query.collide_with_areas = true

	var result = space_state.intersect_ray(query)

	return result.collider == player

func _on_navigation_agent_2d_velocity_computed(safe_velocity:Vector2):
	velocity = safe_velocity * movement_speed

	move_and_slide()

func _on_trigger_timer_timeout():
	$Handgun.shoot(global_position, player.global_position, 500, PI / 12)

func _on_handgun_hit(collider: Object):
	hit.emit(collider)

func _on_player_hit(collider: Object):
	if collider == self:
		queue_free()
