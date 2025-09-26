extends Node

enum MouseCursorMode {
	NORMAL,
	AIM
}

enum FpsMode {
	FIXED,
	SYNC,
	UNLIMITED
}

var game_base_resolution: Vector2:
	set(value):
		game_base_resolution = value
		set_resolution_scaling(window_scaling)

var max_fps: int = 60

var mouse_cursor_texture_path: Dictionary = {
	MouseCursorMode.NORMAL: "",
	MouseCursorMode.AIM: "",
}

var current_mouse_type: MouseCursorMode = MouseCursorMode.NORMAL
var current_fps_mode: FpsMode = FpsMode.FIXED
var current_monitor: int = DisplayServer.window_get_current_screen()
var window_scaling: int = 1
var is_full_screen: bool = false
var previous_window_size: Vector2i = Vector2i(240, 135)

var user_settings: UserSettings

func _ready() -> void:
	game_base_resolution = Vector2(
		ProjectSettings.get_setting("display/window/size/viewport_width"),
			ProjectSettings.get_setting("display/window/size/viewport_height")
			)
	print(game_base_resolution)
	setup_window_resolution_options()
	user_settings = UserSettings.load_or_create()
	window_scaling = user_settings.screen_resolution_scaling
	set_resolution_scaling(window_scaling)
	set_max_fps(current_fps_mode)
	process_mode = Node.PROCESS_MODE_ALWAYS
	# set_mouse_cursor(MouseCursorMode.AIM)

func _physics_process(_delta: float) -> void:
	update_current_monitor()
	_go_full_screen()
	_mouse_visibility()


func setup_window_resolution_options() -> void:
	var screen_rect := DisplayServer.screen_get_usable_rect(current_monitor)
	var max_screen_size := Vector2i(screen_rect.size.x, screen_rect.size.y)

	print(game_base_resolution)
	print(max_screen_size)
	print(max_screen_size.x / game_base_resolution.x)


func _check_current_monitor() -> bool:
	return current_monitor != DisplayServer.window_get_current_screen()

func update_current_monitor() -> void:
	if not _check_current_monitor():
		return
	current_monitor = DisplayServer.window_get_current_screen()
	set_max_fps(current_fps_mode)

func set_window_resolution(_resolution: Vector2) -> void:
	is_full_screen = false
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(Vector2i(_resolution))

func set_resolution_scaling(_resolution_scaling: int) -> void:
	var new_window_resolution := game_base_resolution * _resolution_scaling
	window_scaling = _resolution_scaling
	if _resolution_scaling == 5:
		set_fullscreen()
		return
	set_window_resolution(new_window_resolution)
	set_mouse_cursor(current_mouse_type)


func set_max_fps(fps_mode: FpsMode) -> void:
	current_fps_mode = fps_mode
	match fps_mode:
		FpsMode.FIXED:
			Engine.max_fps = max_fps
		FpsMode.SYNC:
			var refresh_rate: int = int(DisplayServer.screen_get_refresh_rate())
			Engine.max_fps = refresh_rate
		FpsMode.UNLIMITED:
			Engine.max_fps = 0

func _go_full_screen() -> void:
	if Engine.is_editor_hint():
		return
	if not Input.is_action_just_pressed("go_full_screen"):
		return
	set_fullscreen()

func set_fullscreen() -> void:
	if not is_full_screen:
		is_full_screen = true
		previous_window_size = DisplayServer.window_get_size()
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		is_full_screen = false
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(previous_window_size)
	pass


func _mouse_visibility() -> void:
	if Engine.is_editor_hint():
		return
	# if not GameManager.is_game_active:
		# Input.mouse_mode = Input.MOUSE_MODE_CONFINED

func set_mouse_cursor(cursor: MouseCursorMode) -> void:
	if mouse_cursor_texture_path[cursor] == "" : return
	var mouse_cursor_texture: Texture2D = load(mouse_cursor_texture_path[cursor])
	var mouse_cursor_image: Image = mouse_cursor_texture.get_image()
	var scaled_image: Image = scale_mouse_cursor(mouse_cursor_image, window_scaling)
	var scaled_texture: ImageTexture = ImageTexture.create_from_image(scaled_image)
	var hotspot: Vector2 = scaled_image.get_size() / 2.0
	
	match cursor:
		MouseCursorMode.NORMAL:
			Input.set_custom_mouse_cursor(scaled_texture)
		MouseCursorMode.AIM:
			Input.set_custom_mouse_cursor(scaled_texture, Input.CURSOR_ARROW, hotspot)
	
	current_mouse_type = cursor

func scale_mouse_cursor(_mouse_cursor: Image, _scale: int) -> Image:
	var new_mouse_cursor: Image = _mouse_cursor.duplicate()
	new_mouse_cursor.resize(
		_mouse_cursor.get_width() * _scale,
		_mouse_cursor.get_height() * _scale,
		Image.INTERPOLATE_NEAREST
	)
	return new_mouse_cursor
