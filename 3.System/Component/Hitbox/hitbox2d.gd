@tool
extends Area2D
class_name HitBox2D
signal hitbox_hit

@export var value: float = 1
@export var collision_shape: CollisionShape2D
@export var reset_after: float = -1

@export_category("Component")
@export var active: bool = true:
	set(value):
		active = value
		if collision_shape:
			collision_shape.disabled = !value

@export var component: ComponentManager.Components = ComponentManager.Components.HIT_BOX
@export var allow_duplicates: bool = false

func register_component() -> void:
	if not ComponentManager.COMPONENT_NAMES.has(component):
		if is_instance_valid(Debugger):
			Debugger.log_error("Invalid component type: %s" % component)
		return
	var owner_node: Node = owner
	if not owner_node or not is_instance_valid(owner_node):
		if is_instance_valid(Debugger):
			Debugger.log_error("Component %s has no valid node" % ComponentManager.COMPONENT_NAMES[component])
		return
	var components: Dictionary[ComponentManager.Components, Array] = owner_node.get_meta("components", {})
	var component_array: Array[Node] = components.get(component, [])
	if not allow_duplicates and component_array.size() > 0:
		if is_instance_valid(Console):
			Console.log_warning("Duplicate component %s rejected for node %s" % [ComponentManager.COMPONENT_NAMES[component], owner_node])
		return
	component_array.append(self)
	components[component] = component_array
	owner_node.set_meta("components", components)
	ComponentManager.register_component(owner_node, component)
	if is_instance_valid(EventBus):
		EventBus.emit_signal("component_added", ComponentManager.COMPONENT_NAMES[component], owner_node)

func unregister_component() -> void:
	if not ComponentManager.COMPONENT_NAMES.has(component):
		if is_instance_valid(Debugger):
			Debugger.log_error("Invalid component type: %s" % component)
		return
	var owner_node: Node = owner
	if not owner_node or not is_instance_valid(owner_node):
		if is_instance_valid(Debugger):
			Debugger.log_error("Component %s has no valid node" % ComponentManager.COMPONENT_NAMES[component])
		return
	var components: Dictionary[ComponentManager.Components, Array] = owner_node.get_meta("components", {})
	var component_array: Array[Node] = components.get(component, [])
	component_array.erase(self)
	if component_array.is_empty():
		components.erase(component)
	else:
		components[component] = component_array
	owner_node.set_meta("components", components)
	ComponentManager.unregister_component(owner_node, component)
	if is_instance_valid(EventBus):
		EventBus.emit_signal("component_removed", ComponentManager.COMPONENT_NAMES[component], owner_node)

func get_component(_component: ComponentManager.Components) -> Node:
	var owner_node: Node = owner
	if owner_node and is_instance_valid(owner_node):
		var component_array: Array[Node] = owner_node.get_meta("components", {}).get(_component, [])
		if component_array.size() > 0 and is_instance_valid(component_array[0]):
			return component_array[0]
	return null



func _enter_tree() -> void:
	if owner:
		owner.set_meta("hitbox", self)

func _exit_tree() -> void:
	if owner:
		owner.remove_meta("hitbox")


func _ready() -> void:
	create_reset_timer()


func update_hitbox() -> void:
	if !active: return
	if reset_timer:
		reset_timer.start()
	hitbox_hit.emit()
	pass



func reset_hitbox() -> void:
	active = false
	get_tree().create_timer(0.01667).timeout.connect(_on_reset_hitbox_timeout)
	pass


func _on_reset_hitbox_timeout() -> void:
	active = true
	pass


var reset_timer: Timer

func create_reset_timer() -> void:
	if reset_after <= 0: return
	reset_timer = Timer.new()
	reset_timer.one_shot = true
	reset_timer.autostart = false
	reset_timer.wait_time = reset_after
	reset_timer.timeout.connect(_on_reset_timer_timeout)
	add_child(reset_timer)
	pass


func _on_reset_timer_timeout() -> void:
	reset_hitbox()
	pass
