extends Node2D
class_name PickupDrop2D

@export var is_active: bool = true
@export var pickup: GameData.Pickup
@export var drop_amount_range: Vector2i = Vector2.ONE
# @export var drop_health_depleted: bool = false

var drop_amount: int
var _min_drop: int
var _max_drop: int

func _enter_tree() -> void:
	if !owner: return
	if owner.has_meta("pickup_drop"):
		owner.get_meta("pickup_drop").append(self)
	else:
		owner.set_meta("pickup_drop", [self])

func _exit_tree() -> void:
	if !owner: return
	owner.get_meta("pickup_drop").erase(self)

func _ready() -> void:
	# if drop_health_depleted:
	# 	connect_health_depleted()
	# drop_amount_range = abs(drop_amount_range)a
	_min_drop = min(drop_amount_range.x, drop_amount_range.y)
	_max_drop = max(drop_amount_range.x, drop_amount_range.y)

func drop_pickup() -> void:
	var _entity_pickup := GameData.get_new_entity_pickup(pickup)
	if !_entity_pickup:
		return

	drop_amount = randi_range(_min_drop, _max_drop)
	drop_amount = int(drop_amount * GameManager.pickup_drop_rate)

	for i in range(drop_amount):
		var _entity_pickup_dup := _entity_pickup.duplicate()
		var _rand_position := Utils.get_rand_pos_circle_range(global_position, 0, 4)
		_entity_pickup_dup.global_position = _rand_position
		ProjectileEngine.projectile_environment.add_child(_entity_pickup_dup)
		pass

# func connect_health_depleted() -> void:
# 	if !owner: return
# 	if !owner.has_meta("health"): return
# 	owner.get_meta("health").health_depleted.connect(_on_health_depleted)

# 	pass

# func _on_health_depleted() -> void:
# 	pass
