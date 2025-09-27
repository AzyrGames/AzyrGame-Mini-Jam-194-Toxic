extends EntityCharacter2D
class_name EntityCharacterRafiz2D


## Turn speed
# @export var turn_speed: float = 5.0


func _ready() -> void:
	super ()
	GameManager.entity_character = self
	_connect_hurt_box()
	connect_weapon()
	_update_phyiscs()

var _mouse_pos: Vector2

var last_collision: KinematicCollision2D

func _physics_process(_delta: float) -> void:
	super (_delta)
	if _target_direction:
		rotation = _target_direction.angle()
	_mouse_pos = get_global_mouse_position()
	_target_direction = (_mouse_pos - global_position).normalized()
	calculate_velocity(_delta)
	last_collision = get_last_slide_collision()
	if last_collision:
		if !last_collision.get_collider() is EntityEnemy2D:
			velocity = velocity.reflect(last_collision.get_normal()) / 1.5 * -1.0
	move_and_slide()
	
	pass

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("action_2"):
		_is_moving = true
	if Input.is_action_just_released("action_2"):
		_is_moving = false

	if Input.is_action_just_pressed("action_1"):
		active_projectile_wrapper(true)
	if Input.is_action_just_released("action_1"):
		active_projectile_wrapper(false)


func connect_weapon() -> void:
	weapon.projectile_spawner_2d.projectile_spawned.connect(_on_weapon_fired)
	pass

func _connect_hurt_box() -> void:
	hurt_box.got_hurt.connect(_on_got_hurt)
	pass

func _on_got_hurt() -> void:
	EventBus.character_got_hut.emit()
	print("yeeeeee")
	pass


func _on_health_depleted() -> void:
	pass


func _on_weapon_fired(_projectile_template: ProjectileTemplate2D) -> void:
	if _projectile_template.custom_data.size() <= 0: return
	if !_projectile_template.custom_data[0] is Dictionary: return
	print(_projectile_template.custom_data[0].get("push_back"))
	if !_projectile_template.custom_data[0].get("push_back"):
		return
	print("Push velocity: ", (- global_position.direction_to(get_global_mouse_position()) *
		_projectile_template.custom_data[0].get("push_back")
		))
	velocity += (- global_position.direction_to(get_global_mouse_position()) *
		_projectile_template.custom_data[0].get("push_back")
		)
	
	pass
