extends EntityEnemy2D


var last_collision: KinematicCollision2D


func _ready() -> void:
	super()
	rotation_degrees = randf_range(0, 180)
	start_timer.start(randf_range(1, 1.5))
	start_timer.timeout.connect(_on_timer_timeout)


func _on_timer_timeout() -> void:
	if weapon:
		weapon.active = true
	pass




func _physics_process(_delta: float) -> void:
	calculate_velocity(_delta)
	last_collision = get_last_slide_collision()
	rotate(deg_to_rad(57) * _delta)
	# print(velocity)
	move_and_slide()
	pass
