@tool
extends BTAction

@export var is_attack: bool = false

# Called to generate a display name for the task (requires @tool).
func _generate_name() -> String:
	return "Set attacking"


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
	if !agent is EntityEnemy2D:
		return FAILURE
	agent = agent as EntityEnemy2D
	if !agent.weapon:
		return FAILURE
	agent.weapon.active = is_attack
	return SUCCESS