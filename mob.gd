extends CharacterBody2D

enum Role { PATROL, GUARD }
enum Behavior { PASSIVE, AGGRESSIVE }

const MOVEMENT_SPEED: float = 200.0
const FOV_DOT_THRESHOLD: float = 0.5
const FOV_DISTANCE: float = 500

@export var role: Role
@export var behavior: Behavior
@export_range(1, 5) var skill_level: int
@export var waypoints: Array[Node2D] = []

var is_dead: bool = false
var has_finnished_watching: bool = false
var current_waypoint_index: int = 0

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var player: Node2D = get_parent().get_node("Player")
@onready var default_position: Vector2 = global_position
@onready var default_rotation: float = rotation

func _ready():
	set_physics_process(false)
	
	# Make sure to not await during _ready.
	call_deferred("actor_setup")


func _process(_delta: float):
	$Gun.get_node("Target").global_position = player.global_position


func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2):
	velocity = safe_velocity


func _on_trigger_timer_timeout():
	$Gun.shoot(PI / 10)


func _on_watch_timer_timeout():
	has_finnished_watching = true


func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame
	set_physics_process(true)


func set_waypoint_iteratively():
	current_waypoint_index += 1
		
	if current_waypoint_index >= waypoints.size():
		current_waypoint_index = 0


func is_player_in_light_of_sight() -> bool:
	var direction_to_player = position.direction_to(player.position)
	var front_facing_vector = transform.x.normalized()

	if direction_to_player.dot(front_facing_vector) < FOV_DOT_THRESHOLD or position.distance_to(player.position) > FOV_DISTANCE:
		return false

	var space_state = get_world_2d().direct_space_state

	var query = PhysicsRayQueryParameters2D.create(position, player.position)
	query.collision_mask = 1
	query.collide_with_areas = true

	var result = space_state.intersect_ray(query)

	return result.collider == player if result.has("collider") else false


func move_to(next_position: Vector2):
	set_movement_target(next_position)

	var next_path_position: Vector2 = navigation_agent.get_next_path_position()

	var new_velocity = global_position.direction_to(next_path_position) * MOVEMENT_SPEED

	# Face the direction of the next path position.
	if velocity.length_squared() > 0:
		rotation = velocity.angle()

	get_node("NavigationAgent2D").set_velocity(new_velocity)

	move_and_slide()


func set_movement_target(movement_target: Vector2):
	navigation_agent.target_position = movement_target


func rotate_to_player():
	rotation = global_position.direction_to(player.global_position).angle()


func is_alerted():
	return false


func hit():
	is_dead = true


func should_die():
	return is_dead


func should_attack():
	return is_player_in_light_of_sight()


func should_patrol():
	return role == Role.PATROL and $WatchTimer.is_stopped() and (navigation_agent.is_navigation_finished() or has_finnished_watching)


func should_guard():
	return role == Role.GUARD and $WatchTimer.is_stopped() and (navigation_agent.is_navigation_finished() or has_finnished_watching)


func should_chase():
	return behavior == Behavior.AGGRESSIVE and (is_alerted() or not is_player_in_light_of_sight())
	

func should_watch():
	return behavior == Behavior.PASSIVE and (is_alerted() or not is_player_in_light_of_sight())


func should_return():
	return $WatchTimer.is_stopped() and navigation_agent.is_navigation_finished()