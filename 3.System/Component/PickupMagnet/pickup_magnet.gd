extends Area2D
class_name PickupMagnet2D


@export var pickup_speed: float = 120
@export var pickup_range: float = 50:
	set(value):
		pickup_range = value
		if _pickup_shape:
			_pickup_shape.radius = value

@export_flags_2d_physics var pickup_mask: int

var _pickup_collision_shape: CollisionShape2D
var _pickup_shape: CircleShape2D

func _enter_tree() -> void:
	owner.set_meta("pickup_magnet", self)

func _exit_tree() -> void:
	if owner:
		owner.remove_meta("pickup_magnet")

func _ready() -> void:
	setup_pickup_area()
	pass

func setup_pickup_area() -> void:
	_pickup_collision_shape = CollisionShape2D.new()
	_pickup_shape = CircleShape2D.new()
	_pickup_shape.radius = pickup_range
	_pickup_collision_shape.shape = _pickup_shape
	add_child(_pickup_collision_shape)
	connect_pickup_signal()
	pass


func connect_pickup_signal() -> void:
	body_entered.connect(_on_body_enterd)
	body_exited.connect(_on_body_exited)
	pass


func _on_body_enterd(body: Node2D) -> void:
	if body is not EntityPickup2D: return
	body.magnet_target = owner
	body.move_speed = pickup_speed
	pass

func _on_body_exited(body: Node2D) -> void:
	if body is not EntityPickup2D: return
	if body.magnet_target == owner:
		body.magnet_target = null
		body.velocity = Vector2.ZERO
