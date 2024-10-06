extends CanvasLayer

@export var player: CharacterBody2D

func _ready():
	if !player:
		push_warning("Player not set in player_gui.gd")
		return

	player.connect("gun_changed", _on_player_gun_changed)
	player.connect("gun_reloaded", _on_player_gun_reloaded)
	player.connect("gun_shot", _on_player_gun_shot)
	player.connect("gun_started_reloading", _on_player_gun_started_reloading)
	player.connect("grenade_thrown", _on_player_grenade_thrown)

func _on_player_gun_changed():
	match player.current_gun.type:
		GunSettings.Type.HANDGUN: $GunName.text = "Handgun"
		GunSettings.Type.SHOTGUN: $GunName.text = "Shotgun"
		GunSettings.Type.RIFLE: $GunName.text = "Rifle"
		_ : "Unknown"
	
	set_gun_ammo()
	set_gun_magazines()


func _on_player_gun_reloaded():
	set_gun_ammo()
	set_gun_magazines()

	$ProgressBar.visible = false

	$ProgressBar/Timer.stop()


func _on_player_gun_shot():
	set_gun_ammo()


func _on_player_gun_started_reloading():
	$ProgressBar.value = 0
	$ProgressBar.visible = true
	$ProgressBar.max_value = GunSettings.STATS[player.current_gun.type][GunSettings.Stat.RELOAD_TIME]

	$ProgressBar/Timer.start()


func _on_player_grenade_thrown():
	$GrenadeCount.text = str(player.grenades) + "/" + str(player.GRENADE_COUNT)
	

func _on_timer_timeout():
	$ProgressBar.value += 0.1


func set_gun_ammo():
	$GunAmmo.text = str(player.current_gun.ammo) + "/" + str(player.current_gun.magazine_size)


func set_gun_magazines():
	$GunMagazines.text = str(player.current_gun.magazines) + "/" + str(player.current_gun.magazine_count)
