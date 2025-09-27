extends Label

@export var bloody_timer: Timer


func _ready() -> void:
	connect_event_bus()
	connect_timer() 

func _physics_process(delta: float) -> void:
	text = str(snappedf(bloody_timer.time_left, 0.001))
	pass


func connect_event_bus() -> void:
	EventBus.character_got_hut.connect(_on_character_got_hurt)
	EventBus.entity_enemy_destroyed.connect(_on_entity_enemy_detroyed)

	pass

func connect_timer() -> void:
	if !bloody_timer: return
	bloody_timer.timeout.connect(_on_bloody_timer_timeout)
	pass


func _on_character_got_hurt() -> void:
	bloody_timer.start(bloody_timer.time_left - 0.5)
	pass

func _on_entity_enemy_detroyed(_enemy: EntityEnemy2D) -> void:
	bloody_timer.start(bloody_timer.time_left + _enemy.bloody_time)
	pass

func _on_bloody_timer_timeout() -> void:
	print("------------------------------")
	pass
