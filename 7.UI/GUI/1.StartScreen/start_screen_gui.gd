extends Control


@onready var start_button := %StartButton as Button
@onready var setting_button := %SettingButton as Button
@onready var exit_game_button := %ExitGameButton as Button


func _ready() -> void:
	start_button.grab_focus()


func _on_start_button_button_up() -> void:
	GameManager.start_game()
	GuiManager.switch_gui_panel(GuiManager.GUIPanel.CLOSED)
	pass


func _on_setting_button_button_up() -> void:
	GuiManager.switch_gui_panel(GuiManager.GUIPanel.SETTING_MENU)
	pass

func _on_exit_game_button_button_up() -> void:
	get_tree().quit()



func _on_credit_button_button_up() -> void:

	pass # Replace with function body.


func _on_creadit_button_pressed() -> void:
	GuiManager.switch_gui_panel(GuiManager.GUIPanel.CREDIT_SCREEN)
	pass # Replace with function body.
