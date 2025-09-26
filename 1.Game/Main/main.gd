extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(ComponentManager.get_all_component_names())
	print(ComponentManager.get_nodes_by_component(ComponentManager.Components.HEALTH))
	print(ComponentManager.get_nodes_by_component(ComponentManager.Components.HURT_BOX))
	print(ComponentManager.get_components_by_node(self))
	print(
		ComponentManager.get_nodes_with_components(
			[
				ComponentManager.Components.HEALTH,
				ComponentManager.Components.HURT_BOX
			]
		)
	)
	pass # Replace with function body.
