class_name Component
extends Node

@export var active: bool = true
@export var component: ComponentManager.Components
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