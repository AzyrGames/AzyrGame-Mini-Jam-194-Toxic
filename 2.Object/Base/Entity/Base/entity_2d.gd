extends CharacterBody2D
class_name Entity2D


@export_category("Property")
@export var move_speed: float = 60
@export var max_speed: float = 300.0:
	set(value):
		max_speed = value
		_update_phyiscs()
## Frames to reach max speed
@export var acceleration_ticks: float = 60.0:
	set(value):
		acceleration_ticks = value
		_update_phyiscs()
## Frames to stop
@export var friction_ticks: float = 30.0:
	set(value):
		friction_ticks = value
		_update_phyiscs()

var _acceleration_value: float = 1500.0
var _friction_value: float = 1000.0
var _target_direction: Vector2 = Vector2.ZERO
var _calculated_velocity: Vector2 = Vector2.ZERO
var _desired_velocity: Vector2 = Vector2.ZERO

var speed_modifier: float = 1.0
var speed_modifier_stack: PackedFloat32Array
var move_direction: Vector2


@export_category("Component")
@export var health: Health
@export var hurt_box: HurtBox2D

var _is_moving: bool = true



func _ready() -> void:
	pass


func _physics_process(_delta: float) -> void:
	pass

func _update_phyiscs() -> void:
	_acceleration_value = max_speed / acceleration_ticks
	_friction_value = max_speed / friction_ticks
	pass

func calculate_velocity(_delta: float) -> Vector2:
	_desired_velocity = _target_direction * max_speed
	if _is_moving and _desired_velocity != Vector2.ZERO:
		_calculated_velocity = _calculated_velocity.move_toward(_desired_velocity, _acceleration_value)
	else:
		_calculated_velocity = _calculated_velocity.move_toward(Vector2.ZERO, _friction_value)
	return _calculated_velocity