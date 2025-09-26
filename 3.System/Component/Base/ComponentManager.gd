# class_name ComponentManager
extends Node

enum Components {HEALTH, HURT_BOX}
const COMPONENT_NAMES: Dictionary[Components, String] = {
	Components.HEALTH: "Health",
	Components.HURT_BOX: "HurtBox"
}
var NAMES_TO_COMPONENTS: Dictionary[String, Components] = {}
var nodes_by_component: Dictionary[Components, Array] = {}

func _ready() -> void:
	for key: Components in COMPONENT_NAMES:
		NAMES_TO_COMPONENTS[COMPONENT_NAMES[key]] = key

func register_component(_node: Node, _component: Components) -> void:
	if not COMPONENT_NAMES.has(_component):
		if is_instance_valid(Console):
			Console.log_warning("Unregistered component %s attempted registration" % _component)
		return
	var _name: String = get_component_name(_component)
	if _node and is_instance_valid(_node):
		var component_array: Array = nodes_by_component.get_or_add(_component, [])
		if !component_array.has(_node):
			component_array.append(_node)
	if is_instance_valid(Debugger):
		Debugger.log_debug("Component %s registered for node %s" % [_name, _node.name])
	if is_instance_valid(EventBus):
		EventBus.emit_signal("component_added", _name, _node)


func unregister_component(_node: Node, _component: Components) -> void:
	if not COMPONENT_NAMES.has(_component):
		if is_instance_valid(Console):
			Console.log_warning("Unregistered component %s attempted registration" % _component)
		return
	var _name: String = get_component_name(_component)
	if _node and is_instance_valid(_node):
		var component_array: Array = nodes_by_component.get_or_add(_component, [])
		if !component_array.has(_node):
			component_array.erase(_node)
	if is_instance_valid(Debugger):
		Debugger.log_debug("Component %s registered for node %s" % [_name, _node.name])
	if is_instance_valid(EventBus):
		EventBus.emit_signal("component_removed", _name, _node)


func get_all_component_names() -> Array[String]:
	return COMPONENT_NAMES.values()

func get_components_by_node(_node: Node) -> Dictionary:
	if not _node or not is_instance_valid(_node):
		if is_instance_valid(Debugger):
			Debugger.log_debug("The node is not valid: %s" % [_node])
		return {}
	if not _node.has_meta("components"):
		if is_instance_valid(Debugger):
			Debugger.log_debug("%s node does not have component" % [_node])
		return {}
	return _node.get_meta("components")

func get_nodes_by_component(_component: Components) -> Array:
	if not COMPONENT_NAMES.has(_component):
		if is_instance_valid(Debugger):
			Debugger.log_debug("Invalid component: %s" % _component)
		return []
	return nodes_by_component.get(_component, []).duplicate()


func get_nodes_with_components(components: Array[Components]) -> Array:
	if components.is_empty():
		return []

	# Get nodes for each component
	var node_arrays: Array[Array] = []
	for component in components:
		var nodes_for_component: Array = get_nodes_by_component(component)
		if nodes_for_component.is_empty():
			# If any component has no nodes, intersection will be empty
			return []
		node_arrays.append(nodes_for_component)

	# Find intersection of all node arrays
	var result: Array = node_arrays[0].duplicate()
	for i in range(1, node_arrays.size()):
		result = result.filter(func(node: Node) -> bool: return node_arrays[i].has(node))

	return result


func get_component_name(_component: Components) -> String:
	if COMPONENT_NAMES.has(_component):
		return COMPONENT_NAMES.get(_component)
	var _debug_message: String = "No component name: " + str(_component)
	Debugger.log_error(_debug_message)
	return ""
