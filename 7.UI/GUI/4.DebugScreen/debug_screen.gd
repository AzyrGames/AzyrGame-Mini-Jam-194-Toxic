extends Control
class_name DebugScreen
var game_metadata: Dictionary

@onready var debug_update: Timer = %DebugUpdate

var vsync_mode := {
	0: "Disabled",
	1: "VSync",
	2: "Adaptive",
	3: "Mailbox"
}

var window_mode := {
	0: "Windowed",
	1: "Minimized",
	2: "Maximized",
	3: "Fullscreen",
	4: "Exclusive Fullscreen"
}

var debug_values := {
	"game_info": "",
	"fps": 0,
	"game_engine": "",
	"memory": 0,
	"display_size": "",
	"display_Hz": 0,
	"window_size": "",
	"window_mode": 0,
	"vsync_mode": 0,
	"cpu_name": "",
	"gpu_name": "",
	"cpu_time": 0,
	"gpu_time": 0,
	"char_pos": Vector2.ZERO,
	"aim_pos": Vector2.ZERO,
	"moving_dir": Vector2.ZERO
}

func update_debug_values() -> void:
	debug_values.game_info = (
		ProjectSettings.get_setting("application/config/name") + " " +
	ProjectSettings.get_setting("application/config/version")
		)
	debug_values.fps = Engine.get_frames_per_second()

	debug_values.game_engine = Engine.get_version_info().string


	debug_values.memory = Debugger.get_memory_usage()
	# debug_values.display_size = str(DisplayServer.screen_get_size().x) + " x " + str(DisplayServer.screen_get_size().y)
	debug_values.display_size = DisplayServer.screen_get_size()
	debug_values.display_hz = snappedf(DisplayServer.screen_get_refresh_rate(), 0.01)


	# debug_values.window_size = str(DisplayServer.window_get_size().x) + " x " + str(DisplayServer.window_get_size().y)
	debug_values.window_size = DisplayServer.window_get_size()
	debug_values.window_mode = DisplayServer.window_get_mode()
	debug_values.vsync_mode = DisplayServer.window_get_vsync_mode()


	debug_values.cpu_name = OS.get_processor_name()
	debug_values.cpu_time = Debugger.get_cpu_process_time()
	if RenderingServer.get_rendering_device():
		debug_values.gpu_name = RenderingServer.get_rendering_device().get_device_name()
	debug_values.gpu_time = Debugger.get_gpu_process_time()


func render_values() -> void:
	update_debug_values()
	%GameInfoLabel.text = str(debug_values.game_info)
	%FpsLabel.text = "Fps: " + str(debug_values.fps)
	%ProcessTimeLabel.text = str(
		"CPU: " + "%.2f" % debug_values.cpu_time + " ms | GPU: " + "%.2f" % debug_values.gpu_time
		)
	%GodotVersionLabel.text = "Godot " + str(debug_values.game_engine)
	%MemoryLabel.text = "Memory: " + str(debug_values.memory) + "MB"

	%CPUInfoLabel.text = str("CPU: " + debug_values.cpu_name)
	%GPUInfoLabel.text = str("GPU: " + debug_values.gpu_name)
	var display_size := str(debug_values.display_size.x) + " x " + str(debug_values.display_size.y)
	%DisplayInfoLabel.text = "Display: " + display_size + " | " + str(debug_values.display_hz) + "Hz"
	%VsyncLabel.text = str("Vsync: " + str(vsync_mode[debug_values.vsync_mode]))
	var window_size := str(debug_values.window_size.x) + " x " + str(debug_values.window_size.y)
	%WindowInfoLabel.text = "Window: " + window_size + " | " + str(
		window_mode[debug_values.window_mode]
		)

	var char_pos := (
		"(" + str(snappedf(debug_values.char_pos.x, 0.0001)) + ", "
		+ str(snappedf(debug_values.char_pos.y, 0.0001)) + ")"
		)
	%CharacterPosLabel.text = "Position: " + char_pos

	var aim_pos := (
		"(" + str(snappedf(debug_values.aim_pos.x, 0.0001)) + ", "
		+ str(snappedf(debug_values.aim_pos.y, 0.0001)) + ")"
		)
	%AimPositionLabel.text = "Aim: " + aim_pos
	var moving_dir := (
		"(" + str(snappedf(debug_values.moving_dir.x, 0.0001)) + ", "
		+ str(snappedf(debug_values.moving_dir.y, 0.0001)) + ")"
		)
	%CharMovingDirLabel.text = "Moving Dir: " + moving_dir

	
func _on_debug_update_timeout() -> void:
	if visible:
		render_values()
