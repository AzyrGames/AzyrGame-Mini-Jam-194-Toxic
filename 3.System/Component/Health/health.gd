extends Node
class_name Health

@export var hit_points: float = 100.0


@export var active: bool = true
@export var component: ComponentManager.Components = ComponentManager.Components.HEALTH
@export var allow_duplicates: bool = false


func _enter_tree() -> void:
	enter_node()

func _exit_tree() -> void:
	exit_node()

func enter_node() -> void:
	register_component()

func exit_node() -> void:
	unregister_component()

func register_component() -> void:
	var owner_node: Node = owner
	if not owner_node:
		if Debugger:
			Debugger.log_error("Component %s has no valid node" % ComponentManager.COMPONENT_NAMES[component])
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
		if Debugger:
			Debugger.log_error("Component %s has no valid node" % ComponentManager.COMPONENT_NAMES[component])
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
