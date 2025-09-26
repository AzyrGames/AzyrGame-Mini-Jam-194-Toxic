extends Node

const SceneManager := preload("uid://c2x646a2anddk")


func instance_node(_file_path: String) -> Node:
	return SceneManager.instance_node(_file_path)


func format_seconds(time : float, use_milliseconds : bool) -> String:
	var minutes := time / 60
	var seconds := fmod(time, 60)
	if not use_milliseconds:
		return "%02d:%02d" % [minutes, seconds]
	var milliseconds := fmod(time, 1) * 1000
	return "%02d:%02d:%03d" % [minutes, seconds, milliseconds]


var _rand_angle : float 
func rand_direction_cirle() -> Vector2:
	_rand_angle = randf() * TAU  # Random angle between 0 and 2π
	return Vector2(cos(_rand_angle), sin(_rand_angle))


func get_rand_pos_circle_range(_origin_pos: Vector2, _range_min: float, _range_max: float) -> Vector2:
	var _rand_direction : Vector2 = rand_direction_cirle()
	var _range_distance : float = randf_range(_range_min, _range_max)
	return _origin_pos + _rand_direction*_range_distance


func get_tick_time() -> float:
	return 1.0 / Engine.physics_ticks_per_second


func random_direction_circle_batch(_amount: int) -> Array[Vector2]:
	if _amount <= 0: return []
	var _batch_direction: Array[Vector2]
	for i in range(_amount):
		_rand_angle = randf() * TAU  # Random angle between 0 and 2π
		_batch_direction.append(Vector2(cos(_rand_angle), sin(_rand_angle)))
	return _batch_direction


var _random_int_min_range : int
var _random_int_max_range : int

var _random_float_min_range : float
var _random_float_max_range : float


func get_random_int_value(value : Vector3i) -> int:
	if value.z == 1:
		_random_int_min_range = value.x - abs(value.y)
		_random_int_max_range = value.x + abs(value.y)
	else :
		_random_int_min_range = min(value.x, value.y)
		_random_int_max_range = max(value.x, value.y)

	randomize()
	return randi_range(_random_int_min_range, _random_int_max_range)


func get_random_float_value(value : Vector3) -> float:
	if value.z == 1:
		_random_float_min_range = value.x - abs(value.y)
		_random_float_max_range = value.x + abs(value.y)
	else:
		_random_float_min_range = min(value.x, value.y)
		_random_float_max_range = max(value.x, value.y)

	randomize()
	return randf_range(_random_float_min_range, _random_float_max_range)
