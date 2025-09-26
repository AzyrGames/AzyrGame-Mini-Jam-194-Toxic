extends Control
class_name SettingMenu

enum AudioBus {
	Master,
	Music,
	SFX
}

@onready var resolution: HBoxContainer = %Resolution
@onready var resolution_label: Label = %ResolutionLabel
@onready var resolution_button: Button = %ResolutionButton
@onready var back_button: Button = %BackButton

# @onready var screen_shake_slicer: HSlider = %ScreenShakeSlicer

@onready var master_volume_slider: HSlider = %MasterVolumeSlider
@onready var music_volume_slider: HSlider = %MusicVolumeSlider
@onready var sfx_volume_slider: HSlider = %SFXVolumeSlider

@onready var master_volume_slider_value: LineEdit = %MasterVolumeSliderValue
@onready var music_volume_slider_value: LineEdit = %MusicVolumeSliderValue
@onready var sfx_volume_slider_value: LineEdit = %SFXVolumeSliderValue


# @onready var screen_shake_label: Label = %ScreenShakeLabel
@onready var master_volume_label: Label = %MasterVolumeLabel
@onready var music_volume_label: Label = %MusicVolumeLabel
@onready var sfx_volume_label: Label = %SFXVolumeLabel

var user_settings: UserSettings

var resolution_scaling_list := [
	GameWindow.game_base_resolution,
	GameWindow.game_base_resolution * 2,
	GameWindow.game_base_resolution * 3,
	GameWindow.game_base_resolution * 4,
]

func _ready() -> void:
	resolution_button.grab_focus()
	user_settings = UserSettings.load_or_create()
	_init_resolution_button()
	# screen_shake_slicer.value = user_settings.screen_shake
	master_volume_slider.value = user_settings.master_volume
	music_volume_slider.value = user_settings.music_volume
	sfx_volume_slider.value = user_settings.sfx_volume
	setup_setting_gui()

func setup_setting_gui() -> void:
	resolution_button.focus_entered.connect(
		resolution_label.set_self_modulate.bind(Color8(255, 255, 255))
		)
	resolution_button.focus_exited.connect(
		resolution_label.set_self_modulate.bind(Color8(156, 156, 156))
		)

	# screen_shake_slicer.focus_entered.connect(
	# 	screen_shake_label.set_self_modulate.bind(Color8(255, 255, 255))
	# 	)
	# screen_shake_slicer.focus_exited.connect(
	# 	screen_shake_label.set_self_modulate.bind(Color8(156, 156, 156))
	# 	)

	master_volume_slider.focus_entered.connect(
		master_volume_label.set_self_modulate.bind(Color8(255, 255, 255))
		)
	master_volume_slider.focus_exited.connect(
		master_volume_label.set_self_modulate.bind(Color8(156, 156, 156))
		)
	music_volume_slider.focus_entered.connect(
		music_volume_label.set_self_modulate.bind(Color8(255, 255, 255))
		)
	music_volume_slider.focus_exited.connect(
		music_volume_label.set_self_modulate.bind(Color8(156, 156, 156))
		)
	sfx_volume_slider.focus_entered.connect(
		sfx_volume_label.set_self_modulate.bind(Color8(255, 255, 255))
		)
	sfx_volume_slider.focus_exited.connect(
		sfx_volume_label.set_self_modulate.bind(Color8(156, 156, 156))
		)
	
func _init_resolution_scalling_list() -> Array:
	# var max_window_resolution := DisplayServer.screen_get_size()
	return []

func _load_user_settings() -> void:
	pass

func _change_resolution_button_value() -> void:
	user_settings.increase_screen_resolution_index()
	resolution_button.text = _format_sreen_resolution_value(
		user_settings.screen_resolution_scaling
		)


func _format_sreen_resolution_value(_screen_resolution_calling: int) -> String:
	var formated_value := ""
	match _screen_resolution_calling:
		5:
			formated_value = "FullScreen"
		_:
			formated_value = str(_screen_resolution_calling) + "x"
	return formated_value

func _init_resolution_button() -> void:
	resolution_button.text = _format_sreen_resolution_value(
		user_settings.screen_resolution_scaling
		)
	GameWindow.set_resolution_scaling(user_settings.screen_resolution_scaling)

func _on_resolution_button_button_up() -> void:
	_change_resolution_button_value()
	GameWindow.set_resolution_scaling(user_settings.screen_resolution_scaling)
	GameWindow.set_mouse_cursor(GameWindow.MouseCursorMode.NORMAL)
	user_settings.save()


func go_back_setting_menu() -> void:
	if GameManager.is_game_active:
		GuiManager.switch_gui_panel(GuiManager.GUIPanel.PAUSE_MENU)
	else:
		GuiManager.switch_gui_panel(GuiManager.GUIPanel.START_SCREEN)

func set_audio_bus_volume(_bus_name: String, value: float) -> void:
	var _bus_index := AudioServer.get_bus_index(_bus_name)
	AudioServer.set_bus_volume_db(_bus_index, linear_to_db(value))
	var _user_settings := UserSettings.load_or_create()


func _on_back_button_button_up() -> void:
	go_back_setting_menu()

func _on_screen_shake_slicer_value_changed(value: float) -> void:
	user_settings.screen_shake = value
	user_settings.save()
	
func _on_master_volume_slider_value_changed(value: float) -> void:
	set_audio_bus_volume("Master", value)
	master_volume_slider_value.text = str(int(value * 100))
	user_settings.master_volume = value
	user_settings.save()
	

func _on_music_volume_slider_value_changed(value: float) -> void:
	set_audio_bus_volume("Music", value)
	music_volume_slider_value.text = str(int(value * 100))
	user_settings.music_volume = value
	user_settings.save()


func _on_sfx_volume_slider_value_changed(value: float) -> void:
	set_audio_bus_volume("SFX", value)
	sfx_volume_slider_value.text = str(int(value * 100))
	user_settings.sfx_volume = value
	user_settings.save()
