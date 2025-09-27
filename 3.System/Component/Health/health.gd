extends Node
class_name Health

# Component properties
@export var component: ComponentManager.Components = ComponentManager.Components.HEALTH
@export var allow_duplicates: bool = false
@export var active: bool = true

# Health properties
@export var hit_points: float = 100.0
@export var max_health: int = 10:
	set(value):
		max_health = value
		max_health_changed.emit()

@export var current_health: int: 
	set(value):
		current_health = value
		if current_health <= 0:
			is_damageable = false
			# invincible_timer.stop()
			health_depleted.emit()
			if !can_negative:
				current_health = 0
		if current_health > max_health:
			if !can_overhealth:
				current_health = max_health
		if current_health == max_health:
			is_max_health = true
		else:
			is_max_health = false
		health_changed.emit()

@export var invincible_duration: = -1
@export var is_damageable: bool = true
@export var can_negative: bool = false
@export var can_overhealth: bool = false

# Signals
signal health_damaged(_value: int)
signal health_changed
signal health_restored
signal health_depleted
signal max_health_changed

# Constants
const CHARACTER_BASE_HEALTH: = 4

# Variables
var _temp_is_damageable: bool
var is_max_health : bool = false
var _is_setup: bool = false
var invincible_timer: Timer

# Built-in functions
func _enter_tree() -> void:
	enter_node()

func _exit_tree() -> void:
	exit_node()

func _ready() -> void:
	current_health = max_health
	# _temp_is_damageable = is_damageable
	pass

func _physics_process(delta: float) -> void:
	atempt_setup()

# Component management
func enter_node() -> void:
	register_component()

func exit_node() -> void:
	unregister_component()

func register_component() -> void:
	var owner_node: Node = owner
	if not owner_node:
		# if Debugger:
			# Debugger.log_error("Component %s has no valid node" % ComponentManager.COMPONENT_NAMES[component])
		return
	var components: Dictionary = owner_node.get_meta("components", {})
	if not allow_duplicates and components.has(component):
		if Console:
			Console.log_warning("Duplicate component %s rejected for node %s" % [ComponentManager.COMPONENT_NAMES[component], owner_node])
		return

	var _component_array : Array = components.get_or_add(component, [])
	if allow_duplicates:
		_component_array.append(self)
	else:
		if _component_array.size() <= 0:
			_component_array.append(self)

	owner_node.set_meta("components", components)

	ComponentManager.register_component(owner_node, component)

	if EventBus:
		EventBus.emit_signal("trait_added", ComponentManager.COMPONENT_NAMES[component], owner_node)

	print("Register component success")

func unregister_component() -> void:
	var owner_node: Node = owner
	if not owner_node:
		# if Debugger:
			# Debugger.log_error("Component %s has no valid node" % ComponentManager.COMPONENT_NAMES[component])
		return

	var components: Dictionary = owner_node.get_meta("components", {})
	components.erase(component)
	owner_node.set_meta("components", components)
	ComponentManager.unregister_component(owner_node, component)
	if EventBus:
		EventBus.emit_signal("trait_removed", ComponentManager.COMPONENT_NAMES[component], owner_node)

func check_component(_component: ComponentManager.Components) -> bool:
	var owner_node: Node = self
	if owner_node:
		return owner_node.get_meta("components", {}).has(_component)
	return false

func get_component(_component: ComponentManager.Components) -> Node:
	var owner_node: Node = self
	if owner_node:
		return owner_node.get_meta("components", {}).get(_component)
	return null

func is_active() -> bool:
	return active

# Health functionality
func atempt_setup() -> void:
	if _is_setup: return
	if !owner: return
	setup_invicible_timer()
	connect_event_bus()
	update_max_health()
	_is_setup = true

func take_damage(value: int) -> void:
	if value <= 0: return
	if !is_damageable: return

	if invincible_duration > 0:
		_temp_is_damageable = is_damageable
		is_damageable = false
		invincible_timer.start()

	current_health -= value
	health_damaged.emit(value)

	if owner:
		if owner.has_meta("hit_flash"):
			owner.get_meta("hit_flash").hitflash()
		if owner.has_meta("hit_sound"):
			owner.get_meta("hit_sound").playing = true
	pass

func heal_health(value: int) -> void:
	if value <= 0: return

	if current_health >= max_health: 
		return

	current_health += value
	health_restored.emit()

func add_health(value: int) -> void:
	current_health += value
	pass

func set_health(_value: int) -> void:
	current_health = _value
	pass

func connect_event_bus() -> void:
	pass

func update_max_health() -> void:
	if owner:
		current_health = max_health
		print(max_health, " : ", current_health)

func setup_invicible_timer() -> void:
	if invincible_duration <= 0: return
	invincible_timer = Timer.new()
	invincible_timer.autostart = false
	invincible_timer.one_shot = true
	invincible_timer.wait_time = invincible_duration *  Utils.get_tick_time()
	invincible_timer.timeout.connect(_on_invincible_timer_timeout)
	add_child(invincible_timer)
	pass


func _on_invincible_timer_timeout() -> void:
	is_damageable = _temp_is_damageable
	pass
