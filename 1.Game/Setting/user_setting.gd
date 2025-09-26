extends Resource
class_name UserSettings

@export var screen_resolution_scaling : int = 1
@export_range(0, 100.0, 1.0) var screen_shake : float = 100.0
@export_range(0, 100.0, 1.0) var master_volume : float = 60.0
@export_range(0, 100.0, 1.0) var music_volume : float = 60.0
@export_range(0, 100.0, 1.0) var sfx_volume : float = 60.0


const USER_PREFS_PATH : String = "user://user_settings.tres"

func save() -> void:
	ResourceSaver.save(self, USER_PREFS_PATH)
	
static func load_or_create() -> UserSettings:
	var res : UserSettings
	if FileAccess.file_exists(USER_PREFS_PATH):
		res = load(USER_PREFS_PATH) as UserSettings
	else:
		res = UserSettings.new()
	return res

func increase_screen_resolution_index() -> void:
	screen_resolution_scaling += 1
	if screen_resolution_scaling > 4:
		screen_resolution_scaling = 1
