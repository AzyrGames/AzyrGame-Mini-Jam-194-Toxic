extends Node
class_name KnockBack2D



@export var hurtbox: HurtBox2D

var is_knockback : bool = false

var knockback_timer : Timer

## Total knockback distance
@export var knockback_power : float = 10.0
@export var knockback_duration : int = 10
var knockback_direction := Vector2.ZERO

var knockback_tick : int

var _start_position : Vector2
var _stop_position : Vector2


func _ready() -> void:
	# _setup_knockback_timer()
	connect_hurtbox()
	pass

func _physics_process(delta: float) -> void:
	if is_knockback:
		do_knockback()

func connect_hurtbox() -> void:
	# hurtbox.got_hurt.connect(_on_hurtbox_gothurt)
	hurtbox.area_shape_entered.connect(_on_hurtbox_body_shape_entered)
	pass

# func _on_hurtbox_gothurt() -> void:
# 	if owner is BaseEntity2D:
# 		start_knockback()
# 	pass

func _on_hurtbox_body_shape_entered(area_rid:RID, area:Area2D, area_shape_index:int, local_shape_index: int) -> void:
	# print(area.global_position, " - ", owner.global_position)
	if !owner: return
	if !is_instance_valid(area): return
	knockback_direction = area.global_position.direction_to(owner.global_position)
	start_knockback()
	pass


func do_knockback() -> void:
	knockback_tick += 1
	if knockback_tick > knockback_duration:
		knockback_tick = 0
		is_knockback = false
		_stop_position = owner.global_position
		return
	owner.global_position += knockback_direction * (knockback_power / knockback_duration)

	pass

func start_knockback() -> void:
	is_knockback = true
	_start_position = owner.global_position
	pass


func stop_knockback() -> void:
	# if owner is BaseEntity2D:
	is_knockback = false
	pass




# func _setup_knockback_timer() -> void:
# 	knockback_timer = Timer.new()
# 	knockback_timer.autostart = false
# 	knockback_timer.one_shot = true
# 	knockback_timer.wait_time = knockback_duration
# 	knockback_timer.timeout.connect(_on_knockback_timer_timeout)
# 	add_child(knockback_timer)
# 	pass

# func _on_knockback_timer_timeout() -> void:
# 	stop_knockback()
# 	pass
