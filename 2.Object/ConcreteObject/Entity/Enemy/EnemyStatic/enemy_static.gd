extends EntityEnemy2D


var last_collision: KinematicCollision2D

func _ready() -> void:
	super()

func _physics_process(_delta: float) -> void:
	calculate_velocity(_delta)
	last_collision = get_last_slide_collision()
	rotate_texture()
	if last_collision:
		velocity = last_collision.get_normal() * 50
	move_and_slide()
	pass
