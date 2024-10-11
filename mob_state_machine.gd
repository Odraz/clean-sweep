extends StateMachine

enum State { GUARD, PATROL, RETURN, CHASE, WATCH, ATTACK, DEAD }

var last_player_position: Vector2 = Vector2.ZERO

func _ready():
	add_state(State.GUARD)
	add_state(State.PATROL)
	add_state(State.CHASE)
	add_state(State.RETURN)
	add_state(State.WATCH)
	add_state(State.ATTACK)
	add_state(State.DEAD)


	if parent.role == parent.Role.GUARD:
		call_deferred("set_state", State.GUARD)
	elif parent.role == parent.Role.PATROL:
		call_deferred("set_state", State.PATROL)
	else:
		push_error("Unknown role.")


func _state_logic(_delta: float):
	if current_state == State.GUARD or current_state == State.DEAD or current_state == State.WATCH:
		return

	if NavigationServer2D.map_get_iteration_id(parent.navigation_agent.get_navigation_map()) == 0:
		return

	if current_state == State.PATROL:
		if parent.navigation_agent.is_navigation_finished():
			parent.set_waypoint_iteratively()
		
		parent.move_to(parent.waypoints[parent.current_waypoint_index].global_position)

	if current_state == State.CHASE:
		parent.move_to(last_player_position)

	if current_state == State.RETURN:
		if parent.role == parent.Role.GUARD:
			parent.move_to(parent.default_position)
		else:
			parent.move_to(parent.waypoints[parent.current_waypoint_index].global_position)
	
	if current_state == State.ATTACK:
		parent.rotate_to_player()


func _get_transition(_delta: float):
	if parent.should_die():
		return State.DEAD

	match current_state:
		State.DEAD:
			return null
		State.GUARD:
			if parent.should_attack():
				return State.ATTACK
		State.PATROL:
			if parent.should_attack():
				return State.ATTACK
		State.RETURN:
			if parent.should_patrol():
				return State.PATROL
			elif parent.should_guard():
				return State.GUARD
			elif parent.should_attack():
				return State.ATTACK
		State.CHASE:
			if parent.should_return():
				return State.RETURN
			elif parent.should_attack():
				return State.ATTACK
		State.WATCH:
			if parent.should_attack():
				return State.ATTACK
			elif parent.should_patrol():
				return State.PATROL
			elif parent.should_guard():
				return State.GUARD
		State.ATTACK:
			if parent.should_watch():
				return State.WATCH
			elif parent.should_chase():
				return State.CHASE


func _enter_state(_old_state, new_state):
	parent.get_node("TextEdit").text = State.find_key(current_state)

	match new_state:
		State.PATROL:
			play_animation_move()
		State.DEAD:
			# play death animation
			parent.queue_free()
		State.ATTACK:
			play_animation_idle()
			parent.get_node("TriggerTimer").start()
		State.CHASE:
			play_animation_move()
			last_player_position = parent.player.global_position
		State.WATCH:
			play_animation_idle()
			parent.get_node("WatchTimer").start()
		State.GUARD:
			play_animation_idle()
			parent.rotation = parent.default_rotation
		State.RETURN:
			play_animation_move()


func _exit_state(_old_state, _new_state):
	match _old_state:
		State.ATTACK:
			parent.get_node("TriggerTimer").stop()
		State.WATCH:
			parent.has_finnished_watching = false


func play_animation_move():
	parent.get_node("AnimatedSprite2D").play("move")


func play_animation_idle():
	parent.get_node("AnimatedSprite2D").play("idle")