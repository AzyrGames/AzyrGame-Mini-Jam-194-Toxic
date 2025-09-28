extends Area2D
class_name HurtBox2D

# Exported variables
@export var active: bool = true
@export var component: ComponentManager.Components = ComponentManager.Components.HURT_BOX
@export var allow_duplicates: bool = false
@export var is_vulnerable: bool = true
@export var health: Health

# Onready variables
@export var collision_shape: CollisionShape2D

# Regular variables
var is_debug_color_updated: bool = false

# Signals
signal got_hurt

# Lifecycle methods
func _ready() -> void:
	connect_signal()

func _physics_process(delta: float) -> void:
	pass

func _enter_tree() -> void:
	enter_node()

func _exit_tree() -> void:
	exit_node()

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
	
	var _component_array: Array = components.get_or_add(component, [])
	if allow_duplicates:
		_component_array.append(self)
	else:
		if _component_array.size() <= 0:
			_component_array.append(self)
	
	owner_node.set_meta("components", components)
	ComponentManager.register_component(owner_node, component)
	if EventBus:
		EventBus.emit_signal("trait_added", ComponentManager.COMPONENT_NAMES[component], owner_node)
	# print("Register component success")

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

# Active state management
func is_active() -> bool:
	return active

func set_active() -> void:
	collision_shape.disabled = !active
	if active:
		connect_signal()
	else:
		disconnect_signal()

# Signal handling
func connect_signal() -> void:
	if !area_shape_entered.is_connected(_on_area_shape_entered):
		area_shape_entered.connect(_on_area_shape_entered)
	if !area_shape_exited.is_connected(_on_area_shape_exited):
		area_shape_exited.connect(_on_area_shape_exited)

func disconnect_signal() -> void:
	if area_shape_entered.is_connected(_on_area_shape_entered):
		area_shape_entered.disconnect(_on_area_shape_entered)
	if area_shape_exited.is_connected(_on_area_shape_exited):
		area_shape_exited.disconnect(_on_area_shape_exited)

# Collision handling
func _on_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if !is_vulnerable:
		return
	var _damage_value: float = 0
	var _hit_direction: Vector2
	var _hit_position: Vector2
	if area is HitBox2D:
		if health:
			_damage_value = area.value
		_hit_direction = Vector2(randf_range(-1, 0), randf_range(-1, 0)).normalized()
		_hit_position = area.global_position
		got_hurt.emit()
		area.update_hitbox()

	elif ProjectileEngine.projectile_updater_2d_nodes.has(area_rid):
		var _custom_data: Array = ProjectileEngine.projectile_updater_2d_nodes.get(area_rid).custom_data
		_hit_direction = ProjectileEngine.projectile_updater_2d_nodes.get(area_rid).projectile_instance_array[area_shape_index].direction
		_hit_position = ProjectileEngine.projectile_updater_2d_nodes.get(area_rid).projectile_instance_array[area_shape_index].global_position
		if _custom_data.size() > 0:
			if _custom_data[0] is Dictionary:
				if _custom_data[0].has("damage"):
					_damage_value = _custom_data[0]["damage"]
		# print("_hit_direction: ", _hit_direction)
		spawn_particle(_hit_position, _hit_direction)
		got_hurt.emit()
	
	if health:
		# print("healthhhh")
		health.call_deferred("take_damage", _damage_value)

	if owner is EntityCharacter2D:
		spawn_particle(owner.global_position, Utils.rand_direction_cirle())

		EventBus.character_got_hut.emit()

	elif owner is EntityEnemy2D:
		EventBus.enemy_got_hut.emit()
	elif owner is EntityUpgrade2D:
		EventBus.upgrade_got_hut.emit()

	return

func _on_area_shape_exited(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	# if area is HitBox2D:
		# area.has_hurtbox = false
	pass


func spawn_particle(_position: Vector2, _direction: Vector2) -> void:
	if !owner is Entity2D: return

	owner = owner as Entity2D
	if !owner.vfx_blood_splatter: return
	var _vfx_blood_splatter : Node = owner.vfx_blood_splatter.instantiate()
	if !_vfx_blood_splatter is GPUParticles2D: return
	_vfx_blood_splatter = _vfx_blood_splatter as GPUParticles2D
	_direction = _direction * 1.0
	_vfx_blood_splatter.process_material.direction = Vector3(_direction.x, _direction.y, 0)
	_vfx_blood_splatter.global_position = _position
	_vfx_blood_splatter.emitting = true
	ProjectileEngine.projectile_environment.add_child(_vfx_blood_splatter)

	pass
