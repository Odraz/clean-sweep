extends CharacterBody2D

func _on_timer_timeout():
    stand_up()


func brake():
    set_collisions(false)

    $AnimatedSprite2D.play("broken")

    $Timer.start()


func hit():
    brake()


func stand_up():
    set_collisions(true)

    $AnimatedSprite2D.play("default")

    $Timer.stop()


func set_collisions(enabled: bool):
    set_deferred("monitorable", enabled)
    set_deferred("monitoring", enabled)

    $CollisionShape2D.set_deferred("disabled", !enabled)