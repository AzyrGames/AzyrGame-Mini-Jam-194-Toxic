extends Entity2D
class_name EntityEnemy2D

@export var nav_agent: NavigationAgent2D
@export var bt_player: BTPlayer

@export var bloody_time: float = 2.0

@export var start_timer: Timer

@export var asp_entity_death: PackedScene

func _physics_process(_delta: float) -> void:
	super(_delta)
	_target_direction = move_direction
	velocity = calculate_velocity(_delta)
	move_and_slide()




func _on_health_depleted() -> void:
	var _asp_enity_death : Node = asp_entity_death.instantiate()
	if _asp_enity_death is AudioStreamPlayer2D:
		_asp_enity_death.global_position = global_position
		ProjectileEngine.projectile_environment.add_child(_asp_enity_death)
		_asp_enity_death.playing = true
	EventBus.entity_enemy_destroyed.emit(self)
	queue_free()
	pass
