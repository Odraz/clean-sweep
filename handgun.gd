extends Node2D

signal hit (collider: Object)

var end_position: Vector2

func shoot(start_position: Vector2, direction: Vector2, gun_range: float, dispersion: float):
	var space_state = get_world_2d().direct_space_state

	end_position = get_shoot_ray_end_position(start_position, direction, gun_range)

	# Add dispersion to the direction. We want to simulate the bullet not going accurately to the direction but with some angular deviation.
	# The dispersion is a value between 0 and 1. The higher the value, the more the bullet will deviate from the direction.
	# Rotate the end_position around the start_position by a random angle.
	var angle = randf_range(-dispersion / 2, dispersion / 2)

	var diff = end_position - start_position
	end_position = diff.rotated(angle) + start_position

	var query = PhysicsRayQueryParameters2D.create(start_position, end_position)
	query.collide_with_areas = true

	var result = space_state.intersect_ray(query)

	if result:		
		hit.emit(result.collider)

	spawn_bullet(result, start_position, direction)

	# Play the fire sound
	$AudioFire.play()

func spawn_bullet(result: Dictionary, start_position: Vector2, direction: Vector2):
	var bullet_scene = load("res://bullet.tscn")
	var bullet = bullet_scene.instantiate()

	var bullet_start_position = start_position + (direction - start_position).normalized() * 20
	var bullet_end_position = result.position if result else end_position

	bullet.init(bullet_start_position, bullet_end_position)

	add_child(bullet)

func get_shoot_ray_end_position(start_position: Vector2, direction: Vector2, gun_range: float) -> Vector2:
	return start_position + (direction - start_position).normalized() * gun_range