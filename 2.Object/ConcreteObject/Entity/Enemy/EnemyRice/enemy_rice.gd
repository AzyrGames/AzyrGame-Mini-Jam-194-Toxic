extends EntityEnemy2D


func _ready() -> void:
	super()
	_is_moving = true
	rotation_degrees = randf_range(0, 180)
	start_timer.start(randf_range(1, 1.5))
	start_timer.timeout.connect(_on_timer_timeout)


func _physics_process(_delta: float) -> void:
	move_direction = global_position.direction_to(GameManager.entity_character.global_position)
	_target_direction = move_direction
	enemy_sprite.rotate(deg_to_rad(163) * _delta)
	calculate_velocity(_delta)
	move_and_slide()
	pass

func _on_timer_timeout() -> void:
	if weapon:
		weapon.active = true
	pass