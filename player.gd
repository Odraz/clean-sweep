extends CharacterBody2D

signal hit(collider: Object)

@export var speed_walk: float = 150
@export var speed_run: float = 300

var screen_size

func _ready():
	screen_size = get_viewport_rect().size

func _physics_process(delta):
	move_player(delta)

	if Input.is_action_just_pressed("shoot_gun"):
		$Handgun.shoot(position, get_global_mouse_position(), 500, PI / 32)

func move_player(_delta: float):
	var _velocity = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	var is_running = Input.is_action_pressed("move_fast")

	velocity = _velocity * (speed_run if is_running else speed_walk)

	move_and_slide()

	look_at(get_global_mouse_position())

	if velocity.length() > 0:
		$AnimatedSprite2D.play("move")
	else:
		$AnimatedSprite2D.play("idle")
		
func _on_handgun_hit(collider: Object):
	hit.emit(collider)

func _on_mob_hit(collider: Object) -> void:
	if collider == self:
		hide()