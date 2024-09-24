extends CanvasLayer

func _on_player_gun_changed(current_gun: Node2D):
	match current_gun.type:
		GunStats.GunType.HANDGUN: $GunName.text = "Handgun"
		GunStats.GunType.SHOTGUN: $GunName.text = "Shotgun"
		GunStats.GunType.RIFLE: $GunName.text = "Rifle"
		_ : "Unknown"
	
	set_gun_ammo(current_gun)
	set_gun_magazines(current_gun)


func _on_player_gun_reloaded(current_gun: Variant):
	set_gun_ammo(current_gun)
	set_gun_magazines(current_gun)

	$ProgressBar.visible = false

	$ProgressBar/Timer.stop()


func _on_player_gun_shot(current_gun: Variant):
	set_gun_ammo(current_gun)


func set_gun_ammo(current_gun: Variant):
	$GunAmmo.text = str(current_gun.ammo) + "/" + str(current_gun.magazine_size)


func set_gun_magazines(current_gun: Variant):
	$GunMagazines.text = str(current_gun.magazines) + "/" + str(current_gun.magazine_count)


func _on_player_gun_started_reloading(current_gun: Variant):
	$ProgressBar.value = 0
	$ProgressBar.visible = true
	$ProgressBar.max_value = GunStats.GUN_STATS[current_gun.type][GunStats.GunStat.RELOAD_TIME] # 1 is 1 second, 2 is 2 seconds, etc.

	$ProgressBar/Timer.start()


func _on_timer_timeout():
	$ProgressBar.value += 0.1