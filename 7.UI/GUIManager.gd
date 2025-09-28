extends Control


enum GUIPanel {
	START_SCREEN,
	PAUSE_MENU,
	SETTING_MENU,
	CREDIT_SCREEN,
	END_SCREEN,
	DEBUG_SCREEN,
	CLOSED,
}

var gui_panel_path: Dictionary[GUIPanel, String] = {
	GUIPanel.START_SCREEN: "uid://bgjhgbgk5lff8",
	GUIPanel.PAUSE_MENU: "uid://ndwe8omip53i",
	GUIPanel.SETTING_MENU: "uid://ck38yj3c6805l",
	GUIPanel.DEBUG_SCREEN: "uid://f0c7c8miocvv",
	GUIPanel.CREDIT_SCREEN: "uid://ch7lb2nydwvvv",
	GUIPanel.END_SCREEN: "uid://dxqqschunersa",

}

var active_gui_panel: Dictionary[GUIPanel, Control]
var current_gui_panel: GUIPanel

var is_playing: bool = false

var canvas_layer: CanvasLayer


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	setup_gui_manager()
	pass

func setup_gui_manager() -> void:
	is_playing = true
	set_deferred("anchors_preset", Control.PRESET_FULL_RECT)
	# set_anchors_preset(Control.PRESET_FULL_RECT)
	size = GameWindow.game_base_resolution

	z_index = 10
	init_all_gui_panel()

	current_gui_panel = GUIPanel.CLOSED

	pass


func init_all_gui_panel() -> void:
	canvas_layer = CanvasLayer.new()
	add_child(canvas_layer, true)
	for gui_panel: GUIPanel in gui_panel_path.keys():
		var _panel_node: Node = Utils.instance_node(gui_panel_path.get(gui_panel))
		# print(_panel_node)
		if !_panel_node:
			continue
		if _panel_node is Control:
			_panel_node.visible = false
			active_gui_panel[gui_panel] = _panel_node
			canvas_layer.add_child(_panel_node, true)
		pass
	pass


func _input(event: InputEvent) -> void:
	# if !is_playing: return
	if event is InputEventKey:
		if event.is_action_pressed("ui_cancel"):
			handle_ui_cancel()
		if event.is_action_pressed("ui_debug_menu"):
			handle_debug_menu()
	elif event is InputEventJoypadButton:
		if event.is_action_pressed("ui_cancel"):
			handle_ui_cancel()

func handle_ui_cancel() -> void:
	match current_gui_panel:
		GUIPanel.CLOSED:
			switch_gui_panel(GUIPanel.PAUSE_MENU)
			GameManager.set_game_paused(true)
		GUIPanel.SETTING_MENU:
			if GameManager.is_game_active:
				switch_gui_panel(GUIPanel.PAUSE_MENU)
			else:
				switch_gui_panel(GUIPanel.START_SCREEN)
		GUIPanel.PAUSE_MENU:
			switch_gui_panel(GUIPanel.CLOSED)
			GameManager.set_game_paused(false)



func handle_debug_menu() -> void:
	active_gui_panel[GUIPanel.DEBUG_SCREEN].visible = !active_gui_panel[GUIPanel.DEBUG_SCREEN].visible
	pass


func switch_gui_panel(_target_panel: GUIPanel) -> void:
	if _target_panel == GUIPanel.START_SCREEN:
		pass
		# EventBus.switch_background.emit(GameData.MusicSong.MAIN_MENU)
	if _target_panel == GUIPanel.DEBUG_SCREEN:
		return
	if _target_panel == GUIPanel.CLOSED:
		active_gui_panel[current_gui_panel].visible = false
		current_gui_panel = GUIPanel.CLOSED
		GameWindow.set_mouse_cursor(GameWindow.MouseCursorMode.AIM)
	else:
		if current_gui_panel != GUIPanel.CLOSED:
			if active_gui_panel.has(current_gui_panel):
				active_gui_panel[current_gui_panel].visible = false
		current_gui_panel = _target_panel
		if active_gui_panel.has(current_gui_panel):
			active_gui_panel[current_gui_panel].visible = true
		GameWindow.set_mouse_cursor(GameWindow.MouseCursorMode.NORMAL)
	pass

func get_gui_panel_screen_position() -> Vector2:
	# print("camera: ", GameManager.current_camera)
	if !GameManager.current_camera:
		return Vector2.ZERO
	# var _menu_camera_offset := GameWindow.GAME_BASE_RESOLUTION / 2.0
	# var _menu_position: Vector2 = GameManager.current_camera.global_position - _menu_camera_offset
	# return _menu_position
	return Vector2.ZERO
