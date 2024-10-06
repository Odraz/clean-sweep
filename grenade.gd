extends RigidBody2D

const EXPLOSION_RADIUS = 150

@onready var blast_scene = preload("res://grenade_blast.tscn")

func _on_timer_timeout():
	explode()


func _on_queue_free_timeout():
	queue_free()


func explode():
	$AudioExplosion.play()
	$Sprite2D.hide()
	$CollisionShape2D.disabled = true
	$Area2D.get_node("CollisionShape2D").disabled = true

	spawn_blast()

	var destructibles = get_tree().get_nodes_in_group("destructibles")
	var characters = get_tree().get_nodes_in_group("characters")

	destructibles.append_array(characters)

	for hitable in destructibles:
		var hitable_position = hitable.global_position
		var distance = global_position.distance_to(hitable_position)

		if distance < EXPLOSION_RADIUS:
			var space_state = get_world_2d().direct_space_state

			var query = PhysicsRayQueryParameters2D.create(global_position, hitable_position)

			query.collision_mask = 9 # 1001, where 1 are objects and 4 is the layer of the destructibles
			query.collide_with_areas = true

			var result = space_state.intersect_ray(query)
			
			if result.has("collider") and result.collider == hitable and result.collider.has_method("hit"):
				result.collider.hit()
				

func spawn_blast():
	var explosion = blast_scene.instantiate()

	explosion.global_position = global_position

	get_tree().current_scene.add_child(explosion)
