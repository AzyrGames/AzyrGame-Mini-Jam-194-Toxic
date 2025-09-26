@tool
extends BTAction

# Called to generate a display name for the task (requires @tool).
func _generate_name() -> String:
	return "Move to target position"


# Called to initialize the task.
func _setup() -> void:
	pass

# Called when the task is entered.
func _enter() -> void:
	pass

# Called when the task is exited.
func _exit() -> void:
	pass

# Called each time this task is ticked (aka executed).
func _tick(_delta: float) -> Status:
	if agent is not EntityEnemy2D: return FAILURE

	agent = agent as EntityEnemy2D
	if !agent.nav_agent: return FAILURE
	agent._is_moving = true
	agent.move_direction = agent.global_position.direction_to(agent.nav_agent.get_next_path_position())
	if agent.nav_agent.distance_to_target() < 2:
		agent._is_moving = false
		return SUCCESS

	return FAILURE
