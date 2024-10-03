extends Area2D

func _on_area_entered(_area: Area2D):
    set_deferred("monitorable", false)
    set_deferred("monitoring", false)

    $AnimatedSprite2D.play("broken")
    $AudioStreamPlayer2D.play()