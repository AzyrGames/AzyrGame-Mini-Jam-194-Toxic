extends Entity2D
class_name EntityEnemy2D

@export var nav_agent: NavigationAgent2D
@export var bt_player: BTPlayer


func _physics_process(_delta: float) -> void:
	super(_delta)
	_target_direction = move_direction
	velocity = calculate_velocity(_delta)
	move_and_slide()
