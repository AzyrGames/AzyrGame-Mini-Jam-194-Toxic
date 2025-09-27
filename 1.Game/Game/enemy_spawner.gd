extends Node2D
class_name EnemySpawner

signal enemy_wave_cleared

enum EnemyType {
	SQUARE,
	CIRCLE,
	TRIANGLE,
	RICE,
	STATIC,

}


var enemy_power : Dictionary[EnemyType, float] = {
	EnemyType.SQUARE: 3,
	EnemyType.CIRCLE: 5,
	EnemyType.TRIANGLE: 7,
	EnemyType.RICE: 7,
	EnemyType.STATIC: 7,

}


var enemy_random_weight : Dictionary[EnemyType, float] = {
	EnemyType.SQUARE: 10,
	EnemyType.CIRCLE: 8,
	EnemyType.TRIANGLE: 6,
	EnemyType.RICE: 7,
	EnemyType.STATIC: 7,

}


var enemy_array: Array[EntityEnemy2D]



var enemy_paths: Dictionary[EnemyType, String] = {
	EnemyType.SQUARE: "uid://dojfpl5mjxea7",
	EnemyType.CIRCLE: "uid://dcs42iltjwhlg",
	EnemyType.TRIANGLE: "uid://dtpu2d4ruviai",
	EnemyType.RICE: "uid://cavpoab3f6qnj",
	EnemyType.STATIC: "uid://dal7i1lf0v658",

}



@export var spawn_size_x: Vector3 = Vector3(-50, 50, 0)
@export var spawn_size_y: Vector3 = Vector3(-50, 50, 0)



func _ready() -> void:
	connect_event_bus()
	spawn_enemy_wave()

	pass


var current_wave : int = 0
var weight_scale : float = 5


func spawn_enemy_wave() -> void:
	current_wave += 1
	var _enemy_array : Array[EnemyType] = select_enemies(current_wave * weight_scale, 10)
	for _type : EnemyType in _enemy_array:
		spawn_enemy(_type, get_valid_spawn_position())
	pass


func get_valid_spawn_position() -> Vector2:
	var _posible_position: Vector2
	
	for i in range(5000):
		_posible_position.x = Utils.get_random_float_value(spawn_size_x)
		_posible_position.y = Utils.get_random_float_value(spawn_size_y)

		if _posible_position.distance_to(GameManager.entity_character.global_position) < 30:
			print("Baddy: ", _posible_position)
			continue

		return _posible_position
	return Vector2.ZERO

func spawn_enemy(_enemy: EnemyType, _position: Vector2) -> void:
	var _enemy_path := enemy_paths[_enemy]
	var _node := Utils.instance_node(_enemy_path)
	if !_node is EntityEnemy2D: return
	enemy_array.append(_node)
	_node.global_position = _position
	add_child(_node)
	_node.owner = owner
	pass



func select_enemies(target_power: float, threshold: float) -> Array[EnemyType]:
	var selected_enemies: Array[EnemyType] = []
	var current_power: float = 0.0
	
	# Use the threshold parameter directly as the power threshold
	var power_threshold: float = threshold
	
	# Create weighted list for random selection, filtered by power threshold
	var weighted_types: Array = []
	for type in enemy_random_weight:
		if enemy_power[type] <= power_threshold:
			for i in range(int(enemy_random_weight[type] * 100)): # Multiply by 100 for finer weight control
				weighted_types.append(type)
	
	if weighted_types.is_empty():
		return []
	
	# Keep adding enemies until we reach or exceed target power
	while current_power < target_power:
		# Pick a random enemy type based on weights
		var random_type : Variant = weighted_types[randi() % weighted_types.size()]
		
		# Check if adding this enemy exceeds target power significantly
		if current_power + enemy_power[random_type] <= target_power + 0.1: # Small buffer for floating-point precision
			selected_enemies.append(random_type)
			current_power += enemy_power[random_type]
		else:
			# If adding this enemy would overshoot too much, try to find a best fit
			var best_type : EnemyType
			var best_diff := INF
			for type : EnemyType in enemy_power.keys():
				if enemy_power[type] <= power_threshold:
					var new_power := current_power + enemy_power[type]
					var diff : float = abs(target_power - new_power)
					if new_power <= target_power + 0.1 and diff < best_diff:
						best_diff = diff
						best_type = type
			
			if best_type != null:
				selected_enemies.append(best_type)
				current_power += enemy_power[best_type]
			else:
				break # No suitable enemy found, exit loop
	
	return selected_enemies


func connect_event_bus() -> void:
	EventBus.entity_enemy_destroyed.connect(_on_entity_enemy_detroyed)
	EventBus.enemy_wave_cleared.connect(_on_enemy_wave_cleared)
	EventBus.start_new_wave.connect(_on_start_new_wave)




func _on_entity_enemy_detroyed(_enemy: EntityEnemy2D) -> void:
	# _on_entity_enemy_detroyed
	if !enemy_array.has(_enemy): return
	enemy_array.erase(_enemy)

	if enemy_array.size() <= 0 :
		EventBus.enemy_wave_cleared.emit(current_wave)
	pass


func _on_enemy_wave_cleared(_wave:int) -> void:
	# spawn_enemy_wave()
	pass


func _on_start_new_wave() -> void:
	spawn_enemy_wave()
	pass
