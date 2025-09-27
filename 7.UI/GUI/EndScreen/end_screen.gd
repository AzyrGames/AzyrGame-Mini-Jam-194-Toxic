extends Control



@onready var wave_label: Label = %WaveLabel
@onready var survive_time: Label = %SurviveTime

var current_wave : int = 0
var high_wave : int = 0
var high_time : float = 0


func _ready() -> void:
	connect_event_bus()

func connect_event_bus() -> void:
	EventBus.enemy_wave_cleared.connect(_on_wave_cleared)


func _physics_process(delta: float) -> void:
	if !visible: return
	else:
		update_screen()
	pass


func update_screen() -> void:
	var _survival_time := GameManager.main_2d.GAME_TIME_LIMIT - GameManager.main_2d.game_timer.time_left
	if _survival_time > high_time:
		high_time = _survival_time
	var _format_survival_time: String = Utils.format_seconds(_survival_time, true)
	var _format_high_time: String = Utils.format_seconds(high_time, true)

	# var _high_time: = 
	survive_time.text = "Survival Time: " + _format_survival_time + " - " + "High: " + _format_high_time
	wave_label.text = "Last wave: " + str(current_wave) + " - " + "Highest Wave: " + str(high_wave)




func _on_wave_cleared(_wave: int) -> void:
	current_wave = _wave
	if high_wave < _wave:
		high_wave = _wave

func _on_new_game_button_pressed() -> void:
	current_wave = 0
	GameManager.start_game()

	GuiManager.switch_gui_panel(GuiManager.GUIPanel.CLOSED)
	GameManager.toggle_pause()

	# GuiManager.switch_gui_panel(GuiManager.GUIPanel.DIFFICULTY_SELECTION)
	pass # Replace with function body.

func _on_back_button_pressed() -> void:
	current_wave = 0
	GameManager.stop_game()
	GuiManager.switch_gui_panel(GuiManager.GUIPanel.START_SCREEN)
	GameManager.toggle_pause()
	pass # Replace with function body.
