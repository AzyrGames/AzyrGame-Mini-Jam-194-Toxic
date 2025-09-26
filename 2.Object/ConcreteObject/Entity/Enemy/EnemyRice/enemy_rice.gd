extends EntityEnemy2D


func _ready() -> void:
	super()
	_is_moving = true

func _physics_process(_delta: float) -> void:
	move_direction = global_position.direction_to(GameManager.entity_character.global_position)
	_target_direction = move_direction
	rotate_texture()
	calculate_velocity(_delta)
	move_and_slide()
	pass