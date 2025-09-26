extends Node
# class_name Debugger


var log_file: FileAccess
var smoothed_cpu_time: float = 0.0
var smoothed_gpu_time: float = 0.0
const SMOOTH_FACTOR := 0.8

func _ready() -> void:
	log_file = FileAccess.open("user://debug_log.txt", FileAccess.WRITE)
	if log_file == null:
		push_error("Failed to open debug log file")

func log_debug(message: String) -> void:
	var timestamp: String = Time.get_datetime_string_from_system(true, true)
	var log_line: String = "[%s] [DEBUG] %s" % [timestamp, message]
	print(log_line)
	if log_file:
		log_file.store_line(log_line)

func log_error(message: String) -> void:
	var timestamp: String = Time.get_datetime_string_from_system(true, true)
	var log_line: String = "[%s] [ERROR] %s" % [timestamp, message]
	push_error(log_line)
	if log_file:
		log_file.store_line(log_line)



func get_memory_usage() -> float:
	var memory : float = OS.get_static_memory_usage() / 1024.0 / 1024.0
	memory = snappedf(memory, 0.01)
	return memory


func get_cpu_process_time(_smooth: bool = false) -> float:
	var cpu_time : float = RenderingServer.viewport_get_measured_render_time_cpu(get_tree().root.get_viewport_rid()) + RenderingServer.get_frame_setup_time_cpu()
	if _smooth:
		smoothed_cpu_time = smoothed_cpu_time * SMOOTH_FACTOR + cpu_time * (1.0 - SMOOTH_FACTOR)
		cpu_time = smoothed_cpu_time
	cpu_time = snappedf(cpu_time, 0.01)
	return cpu_time


func get_gpu_process_time(_smooth: bool = false) -> float:
	var gpu_time := RenderingServer.viewport_get_measured_render_time_gpu(get_tree().root.get_viewport_rid())
	if _smooth:
		smoothed_gpu_time = smoothed_gpu_time * SMOOTH_FACTOR + gpu_time * (1.0 - SMOOTH_FACTOR)
		gpu_time = smoothed_gpu_time
	gpu_time = snappedf(gpu_time, 0.01)
	return gpu_time


func toggle_visible_collision() -> void:
	var tree := get_tree()
	tree.debug_collisions_hint = not tree.debug_collisions_hint
	
	var node_stack: Array[Node] = [tree.get_root()]
	while not node_stack.is_empty():
		var node: Node = node_stack.pop_back()
		if not is_instance_valid(node):
			continue
		if node is CollisionShape2D or node is CollisionPolygon2D:
			node.queue_redraw()
		if node is TileMapLayer:
			match node.collision_visibility_mode:
				TileMapLayer.DEBUG_VISIBILITY_MODE_FORCE_SHOW:
					node.collision_visibility_mode = TileMapLayer.DEBUG_VISIBILITY_MODE_DEFAULT
				TileMapLayer.DEBUG_VISIBILITY_MODE_DEFAULT:
					node.collision_visibility_mode = TileMapLayer.DEBUG_VISIBILITY_MODE_FORCE_SHOW
		node_stack.append_array(node.get_children())

func toggle_visible_path() -> void:
	var tree := get_tree()
	tree.debug_paths_hint = not tree.debug_paths_hint
	
	var node_stack: Array[Node] = [tree.get_root()]
	while not node_stack.is_empty():
		var node: Node = node_stack.pop_back()
		if not is_instance_valid(node):
			continue
		if node is NavigationAgent2D:
			node.debug_enabled = not node.debug_enabled
		node_stack.append_array(node.get_children())


func toggle_visible_navigation() -> void:
	var tree := get_tree()
	tree.debug_navigation_hint = not tree.debug_navigation_hint
	
	var node_stack: Array[Node] = [tree.get_root()]
	while not node_stack.is_empty():
		var node: Node = node_stack.pop_back()
		if not is_instance_valid(node):
			continue
		if node is TileMapLayer:
			match node.navigation_visibility_mode:
				TileMapLayer.DEBUG_VISIBILITY_MODE_FORCE_SHOW:
					node.navigation_visibility_mode = TileMapLayer.DEBUG_VISIBILITY_MODE_DEFAULT
				TileMapLayer.DEBUG_VISIBILITY_MODE_DEFAULT:
					node.navigation_visibility_mode = TileMapLayer.DEBUG_VISIBILITY_MODE_FORCE_SHOW
		node_stack.append_array(node.get_children())
