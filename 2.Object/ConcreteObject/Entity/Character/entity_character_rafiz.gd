extends EntityCharacter2D
class_name EntityCharacterRafiz2D


## Turn speed
# @export var turn_speed: float = 5.0


func _ready() -> void:
	super()
	_update_phyiscs()

var _mouse_pos: Vector2


func _physics_process(_delta: float) -> void:
	super(_delta)
	if _target_direction:
		rotation = _target_direction.angle()
	_mouse_pos = get_global_mouse_position()
	_target_direction = (_mouse_pos - global_position).normalized()
	velocity = calculate_velocity(_delta)
	move_and_slide()
	pass


func _input(event: InputEvent) -> void:
	if Input.is_action_pressed("action_2"):
		_is_moving = true
	else:
		_is_moving = false


	pass
