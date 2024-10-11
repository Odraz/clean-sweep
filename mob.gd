extends CharacterBody2D

enum Role { PATROL, GUARD }
enum Behavior { PASSIVE, AGGRESSIVE }

enum Skill { REACTION_TIME, ACCURACY, DISTANCE, FOV_DOT_THRESHOLD }

const SKILL_LEVELS: Dictionary = {
	1: { Skill.REACTION_TIME: 0.4, Skill.ACCURACY: PI / 8, Skill.DISTANCE: 400, Skill.FOV_DOT_THRESHOLD: 0.5 },
	2: { Skill.REACTION_TIME: 0.35, Skill.ACCURACY: PI / 9, Skill.DISTANCE: 450, Skill.FOV_DOT_THRESHOLD: 0.4 },
	3: { Skill.REACTION_TIME: 0.3, Skill.ACCURACY: PI / 10, Skill.DISTANCE: 500, Skill.FOV_DOT_THRESHOLD: 0.3 },
	4: { Skill.REACTION_TIME: 0.25, Skill.ACCURACY: PI / 11, Skill.DISTANCE: 550, Skill.FOV_DOT_THRESHOLD: 0.2 },
	5: { Skill.REACTION_TIME: 0.2, Skill.ACCURACY: PI / 12, Skill.DISTANCE: 700, Skill.FOV_DOT_THRESHOLD: 0.1 }
}

const SPEED_WALK: float = 150.0
const SPEED_RUN: float = 200.0

@export var role: Role
@export var behavior: Behavior
@export_range(1, 5) var skill_level: int = 1
@export var waypoints: Array[Node2D] = []

var is_dead: bool = false
var has_finnished_watching: bool = false
var has_finnished_alerting: bool = false
var current_waypoint_index: int = 0
var noise_origin: Vector2

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var player: Node2D = get_parent().get_node("Player")
@onready var default_position: Vector2 = global_position
@onready var default_rotation: float = rotation

func _ready():
	$TriggerTimer.wait_time = SKILL_LEVELS[skill_level][Skill.REACTION_TIME]

	SignalBus.noise_made.connect(_on_noise_made)

	set_physics_process(false)
	
	# Make sure to not await during _ready.
	call_deferred("actor_setup")


func _process(_delta: float):
	$Gun.get_node("Target").global_position = player.global_position


func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2):
	velocity = safe_velocity


func _on_trigger_timer_timeout():
	$Gun.shoot(SKILL_LEVELS[skill_level][Skill.ACCURACY])


func _on_watch_timer_timeout():
	has_finnished_watching = true


func _on_alert_timer_timeout():
	has_finnished_alerting = true


func _on_noise_made(origin: Vector2, intensity: float):
	if not is_player_in_light_of_sight() and global_position.distance_to(origin) < intensity:
		noise_origin = origin
		$AlertTimer.start()


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

	if direction_to_player.dot(front_facing_vector) < SKILL_LEVELS[skill_level][Skill.ACCURACY]  or position.distance_to(player.position) > SKILL_LEVELS[skill_level][Skill.DISTANCE]:
		return false

	var space_state = get_world_2d().direct_space_state

	var query = PhysicsRayQueryParameters2D.create(position, player.position)
	query.collision_mask = 1
	query.collide_with_areas = true

	var result = space_state.intersect_ray(query)

	return result.collider == player if result.has("collider") else false


func move_to(next_position: Vector2, is_running: bool):
	set_movement_target(next_position)

	var next_path_position: Vector2 = navigation_agent.get_next_path_position()

	var new_velocity = global_position.direction_to(next_path_position) * (SPEED_RUN if is_running else SPEED_WALK)

	# Face the direction of the next path position.
	if velocity.length_squared() > 0:
		rotation = velocity.angle()

	get_node("NavigationAgent2D").set_velocity(new_velocity)

	move_and_slide()


func set_movement_target(movement_target: Vector2):
	navigation_agent.target_position = movement_target


func rotate_to_player():
	rotation = global_position.direction_to(player.global_position).angle()


func hit():
	is_dead = true


func should_die():
	return is_dead


func should_attack():
	return is_player_in_light_of_sight()


func should_patrol():
	return role == Role.PATROL and $WatchTimer.is_stopped() and (navigation_agent.is_navigation_finished() or has_finnished_watching or has_finnished_alerting)


func should_guard():
	return role == Role.GUARD and $WatchTimer.is_stopped() and (navigation_agent.is_navigation_finished() or has_finnished_watching or has_finnished_alerting)


func should_chase():
	return behavior == Behavior.AGGRESSIVE and not is_player_in_light_of_sight()
	

func should_watch():
	return behavior == Behavior.PASSIVE and not is_player_in_light_of_sight()


func should_return():
	return $WatchTimer.is_stopped() and $AlertTimer.is_stopped() and (navigation_agent.is_navigation_finished() or has_finnished_watching or has_finnished_alerting)


func should_alert():
	return not $AlertTimer.is_stopped()