extends Node

static func instance_node(_file_path: String) -> Node:
	var _packed_scene : PackedScene = load(_file_path)
	if !_packed_scene:
		print_debug("Scene not valid: " + _file_path)
		return null
	var _node_instance : Node = _packed_scene.instantiate()
	if !_node_instance:
		print_debug("Node not valid: " + _file_path)
		return null
	return _node_instance
