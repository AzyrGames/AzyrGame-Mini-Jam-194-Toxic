extends Control

@onready var resume_button := %ResumeButton as Button
@onready var setting_button := %SettingButton as Button
@onready var go_to_start_screen_button := %GoToStartScreenButton as Button

func _ready() -> void:
	resume_button.grab_focus()
	pass


func _on_resume_button_button_up() -> void:
	GuiManager.switch_gui_panel(GuiManager.GUIPanel.CLOSED)
	GameManager.resume_game()
	pass

func _on_setting_button_button_up() -> void:
	GuiManager.switch_gui_panel(GuiManager.GUIPanel.SETTING_MENU)
	pass


func _on_go_to_start_screen_button_button_up() -> void:
	GameManager.clear_game()
	GuiManager.switch_gui_panel(GuiManager.GUIPanel.START_SCREEN)
	GameManager.resume_game()
	GameManager.is_game_active = false
	pass


func _on_exit_game_button_button_up() -> void:
	get_tree().quit()
	pass
