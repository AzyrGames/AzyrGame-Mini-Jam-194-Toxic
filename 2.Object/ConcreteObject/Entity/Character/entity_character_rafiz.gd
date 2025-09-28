extends EntityCharacter2D
class_name EntityCharacterRafiz2D


## Turn speed
# @export var turn_speed: float = 5.0

const WEAPON_DAMAGE: float = 5.0
const WEAPON_SHOOT_SPEED: = 0.4

# const CHARACTER_MAX_SPEED:

@export var asp_moving: AudioStreamPlayer2D

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
	if velocity != Vector2.ZERO:
		if !asp_moving.playing:
			asp_moving.playing = true
		asp_moving.volume_db = (1.0 - (velocity.length() / max_speed)) * -15 - 5.0
		# print(1.0 - (velocity.length() / 80.0) * 10)
	else:
		asp_moving.playing = false
	
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


func reset_character() -> void:
	if weapon:
		weapon.projectile_spawner_2d.projectile_template_2d.custom_data[0]["damage"] = WEAPON_DAMAGE
		%TSCRepeater.duration = WEAPON_SHOOT_SPEED
	pass


func add_weapon_damage(_value: int) -> void:
	weapon.projectile_spawner_2d.projectile_template_2d.scale += Vector2(_value * 0.1, _value * 0.1)
	weapon.projectile_spawner_2d.projectile_template_2d.custom_data[0]["damage"] += _value
	pass


func add_weapon_accuracy(_value: int) -> void:
	%PCCSingle2D.rotation_random.y -= _value
	if %PCCSingle2D.rotation_random.y < 0:
		%PCCSingle2D.rotation_random.y = 0 
	pass




func add_weapon_shoot_speed(_value: float) -> void:
	%TSCRepeater.duration -= _value
	pass


func add_mobility() -> void:
	max_speed += 5
	acceleration_ticks -= 5
	friction_ticks -= 10
	pass




func add_weapon_knock_back(_value: int) -> void:
	if weapon.projectile_spawner_2d.projectile_template_2d.custom_data[0]["push_back"] + _value >= 0:
		weapon.projectile_spawner_2d.projectile_template_2d.custom_data[0]["push_back"] += _value
	pass


func connect_weapon() -> void:
	weapon.projectile_spawner_2d.projectile_spawned.connect(_on_weapon_fired)
	pass

func _connect_hurt_box() -> void:
	hurt_box.got_hurt.connect(_on_got_hurt)
	pass

func _on_got_hurt() -> void:
	EventBus.character_got_hut.emit()
	pass


func _on_health_depleted() -> void:
	pass


func _on_weapon_fired(_projectile_template: ProjectileTemplate2D) -> void:
	if _projectile_template.custom_data.size() <= 0: return
	if !_projectile_template.custom_data[0] is Dictionary: return
	if !_projectile_template.custom_data[0].get("push_back"):
		return
	velocity += (- global_position.direction_to(get_global_mouse_position()) *
		_projectile_template.custom_data[0].get("push_back")
		)
	
	pass
