@tool
extends BTAction


# Called to generate a display name for the task (requires @tool).
func _generate_name() -> String:
	return "Start moving random direction"


# Called to initialize the task.
func _setup() -> void:
	pass

# Called when the task is entered.
func _enter() -> void:
	if agent is not EntityEnemy2D: return
	agent = agent as EntityEnemy2D
	agent._is_moving = true
	agent.move_direction = Utils.rand_direction_cirle().normalized()
	print("wa")
	pass

# Called when the task is exited.
func _exit() -> void:
	pass

# Called each time this task is ticked (aka executed).
func _tick(_delta: float) -> Status:
	return SUCCESS