extends Area2D

func _on_area_entered(_area: Area2D):
    brake()


func _on_body_entered(_body: Node2D) -> void:
    if _body.is_in_group("throwables"):
        brake()


func brake():
    set_deferred("monitorable", false)
    set_deferred("monitoring", false)

    $CollisionShape2D.disabled = true

    $AnimatedSprite2D.play("broken")
    $AudioStreamPlayer2D.play()


func hit():
    brake()