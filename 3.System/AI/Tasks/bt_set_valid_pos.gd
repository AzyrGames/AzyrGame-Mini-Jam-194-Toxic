@tool
extends BTAction


@export var random_range: Vector3 = Vector3(20, 50, 0)

const ATTEMP_COUNT: int = 1000
const PLAYER_DISTANCE: int = 32

var _rand_length: float
var _rand_direction: Vector2
var _target_position: Vector2


# Called to generate a display name for the task (requires @tool).
func _generate_name() -> String:
	return "Set target position random point"


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

	for i in range(ATTEMP_COUNT):
		_rand_direction = Utils.rand_direction_cirle()
		_rand_length = Utils.get_random_float_value(random_range)
		_target_position = _rand_direction * _rand_length
		agent.nav_agent.target_position = _target_position
		if agent.nav_agent.is_target_reachable():
			break

	return SUCCESS
