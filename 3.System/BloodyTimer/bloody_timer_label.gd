extends Label
class_name BloodyTimer

const CHARCTER_BLOODY_TIME: float = 0.5
const ENEMY_BLOODY_TIME_BONUS: float = 1.0
const CHARACTER_BLOODY_TIME_BONUS: float = 1.0

const BLODDY_TIME_CAP: float = 30.0


@export var character_bloody_time: float = 0.5

@export var bloody_timer: Timer
@export var bloody_time_cap: float = 30.0
@export var bloody_time_time: float = 30.0:
	set(value):
		if value > bloody_time_cap:
			bloody_time_time = bloody_time_cap
		else:
			bloody_time_time = value

@export var init_time: float = 30.0


@export var enemy_bloody_time_bonus: float = 1.0
@export var character_bloody_time_bonus: float = 1.0
@export var wave_label: Label
@export var survive_time_label: Label



func _ready() -> void:
	connect_event_bus()
	connect_timer()

func _physics_process(delta: float) -> void:
	var time_left := snappedf(bloody_timer.time_left, 0.001)
	text = format_time(time_left)
	var _survival_time := GameManager.main_2d.GAME_TIME_LIMIT - GameManager.main_2d.game_timer.time_left
	# var _format_survival_time: String = Utils.format_seconds(_survival_time, true)

	if survive_time_label:
		survive_time_label.text = format_time(_survival_time)
	pass



func format_time(time_left: float) -> String:
	var minutes := int(time_left / 60)
	var seconds := int(time_left) % 60
	var milliseconds := int((time_left - int(time_left)) * 100)
	return "%02d:%02d.%02d" % [minutes, seconds, milliseconds]


func start_bloody_timer() -> void:
	bloody_time_cap = BLODDY_TIME_CAP
	character_bloody_time = CHARCTER_BLOODY_TIME
	enemy_bloody_time_bonus = ENEMY_BLOODY_TIME_BONUS
	character_bloody_time_bonus = CHARACTER_BLOODY_TIME_BONUS

	bloody_time_time = init_time
	bloody_timer.stop()
	bloody_timer.start(bloody_time_time)


func connect_event_bus() -> void:
	EventBus.character_got_hut.connect(_on_character_got_hurt)
	EventBus.entity_enemy_destroyed.connect(_on_entity_enemy_detroyed)
	EventBus.upgrade_destroyed.connect(_on_upgrade_destroyed)
	pass


func add_bloody_time_cap(_value: float) -> void:
	bloody_time_cap += _value


func add_character_bloody_time(_value: float) -> void:
	character_bloody_time_bonus += _value
	pass


func add_character_bloody_time_bonus(_value: float) -> void:
	character_bloody_time += _value
	pass

func add_enemy_bloody_time_bonus(_value: float) -> void:
	enemy_bloody_time_bonus += _value


func connect_timer() -> void:
	if !bloody_timer: return
	bloody_timer.timeout.connect(_on_bloody_timer_timeout)
	pass


func _on_character_got_hurt() -> void:
	# print(character_bloody_time)
	add_bloody_timer_time(-character_bloody_time * character_bloody_time_bonus)
	pass


func _on_entity_enemy_detroyed(_enemy: EntityEnemy2D) -> void:
	# print("_enemy.bloody_time * enemy_bloody_time_bonus: ", _enemy.bloody_time * enemy_bloody_time_bonus)
	add_bloody_timer_time(_enemy.bloody_time * enemy_bloody_time_bonus)
	pass

func _on_bloody_timer_timeout() -> void:
	GameManager.toggle_pause()
	# GameManager.stop_game()
	await get_tree().create_timer(1.0).timeout
	GuiManager.switch_gui_panel(GuiManager.GUIPanel.END_SCREEN)
	GameManager.main_2d.clear_game()

	# print("------------------------------")
	pass


func _on_upgrade_destroyed(_entity_upgrade: EntityUpgrade2D) -> void:
	add_bloody_timer_time(_entity_upgrade.bloody_time)
	pass


func add_bloody_timer_time(_value: float) -> void:
	bloody_time_time = bloody_timer.time_left + _value
	if bloody_time_time > 0:
		bloody_timer.start(bloody_time_time)
	pass
