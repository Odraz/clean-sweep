extends Node2D

signal hit (collider: CollisionObject2D)

var end_position: Vector2

func shoot(start_position: Vector2, direction: Vector2, gun_range: float, dispersion: float):
	var space_state = get_world_2d().direct_space_state

	end_position = get_shoot_ray_end_position(start_position, direction, gun_range, dispersion)

	var query = PhysicsRayQueryParameters2D.create(start_position, end_position)
	query.collide_with_areas = true

	var result = space_state.intersect_ray(query)

	if result:		
		hit.emit(result.collider)

	spawn_bullet(result, start_position, direction)

func spawn_bullet(result: Dictionary, start_position: Vector2, direction: Vector2):
	var bullet_scene = load("res://bullet.tscn")
	var bullet = bullet_scene.instantiate()

	var bullet_start_position = start_position + (direction - start_position).normalized() * 20
	var bullet_end_position = result.position if result else get_shoot_ray_end_position(start_position, direction, 500, 0)

	bullet.init(bullet_start_position, bullet_end_position)

	add_child(bullet)

func get_shoot_ray_end_position(start_position: Vector2, direction: Vector2, gun_range: float, _dispersion: float) -> Vector2:
	return start_position + (direction - start_position).normalized() * gun_range