extends RigidBody2D

signal hit(collider: Object)

var explosion_radius = 200

func _ready():
	var characters = get_tree().get_nodes_in_group("characters")

	for character in characters:
		connect("hit", character._on_hit)


func _on_timer_timeout() -> void:
	explode()


func explode() -> void:
	$AudioExplosion.play()
	$Sprite2D.hide()
	$CollisionShape2D.disabled = true

	var characters = get_tree().get_nodes_in_group("characters")

	for character in characters:
		var character_position = character.global_position
		var distance = global_position.distance_to(character_position)

		if distance < explosion_radius:
			var space_state = get_world_2d().direct_space_state

			var query = PhysicsRayQueryParameters2D.create(global_position, character_position)
			query.collide_with_areas = true

			var result = space_state.intersect_ray(query)

			if result.has("collider") and result.collider == character:
				hit.emit(character)


func _on_queue_free_timeout():
	queue_free()

