extends EntityEnemy2D


var last_collision: KinematicCollision2D

func _physics_process(_delta: float) -> void:
	_target_direction = move_direction
	rotation = move_direction.angle()
	calculate_velocity(_delta)
	last_collision = get_last_slide_collision()
	if last_collision:
		move_direction = move_direction.bounce(last_collision.get_normal())
		velocity = velocity.bounce(last_collision.get_normal())
	move_and_slide()