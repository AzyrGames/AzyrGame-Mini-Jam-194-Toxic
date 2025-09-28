extends Node
# class_name SaveLoadManager

## Enhanced Save/Load system with multiple save slots
##
## Features:
## - Multiple save slots (configurable)
## - Auto-save functionality
## - Save validation and error handling
## - Quick save/load shortcuts
## - Save slot management

signal save_completed(slot_id: int, success: bool)
signal load_completed(slot_id: int, success: bool)
signal save_slot_deleted(slot_id: int)

const SAVE_DIRECTORY: String = "user://saves/"
const SAVE_FILE_EXTENSION: String = ".tres"
const AUTO_SAVE_SLOT: int = -1

@export var max_save_slots: int = 10
@export var auto_save_enabled: bool = false
@export var auto_save_interval: float = 300.0 # 5 minutes
@export var quick_save_slot: int = 0
@export var allow_auto_save_toggle: bool = true

var current_save_slot: int = 0
var save_states: Dictionary = {} # Dictionary[int, SaveState]
var auto_save_timer: Timer

## Initialize the save system
func _ready() -> void:
	_ensure_save_directory()
	_setup_auto_save()
	_discover_existing_saves()

## Setup auto-save timer
func _setup_auto_save() -> void:
	if auto_save_enabled:
		auto_save_timer = Timer.new()
		auto_save_timer.wait_time = auto_save_interval
		auto_save_timer.timeout.connect(_auto_save)
		auto_save_timer.autostart = true
		add_child(auto_save_timer)

## Toggle auto-save functionality
func toggle_auto_save(enabled: bool = !auto_save_enabled) -> void:
	if not allow_auto_save_toggle:
		Debugger.log_debug("Auto-save toggle is disabled")
		return
	
	auto_save_enabled = enabled
	
	if auto_save_timer:
		if auto_save_enabled:
			auto_save_timer.start()
			Debugger.log_debug("Auto-save enabled")
		else:
			auto_save_timer.stop()
			Debugger.log_debug("Auto-save disabled")
	elif auto_save_enabled:
		# Create timer if it doesn't exist but auto-save is now enabled
		_setup_auto_save()

## Set auto-save interval and restart timer if running
func set_auto_save_interval(interval_seconds: float) -> void:
	auto_save_interval = interval_seconds
	
	if auto_save_timer and auto_save_enabled:
		auto_save_timer.wait_time = auto_save_interval
		auto_save_timer.start() # Restart with new interval
		Debugger.log_debug("Auto-save interval set to %d seconds" % interval_seconds)

## Ensure save directory exists
func _ensure_save_directory() -> void:
	if not DirAccess.dir_exists_absolute(SAVE_DIRECTORY):
		DirAccess.open("user://").make_dir_recursive("saves")

## Discover existing save files
func _discover_existing_saves() -> void:
	var dir: DirAccess = DirAccess.open(SAVE_DIRECTORY)
	if dir == null:
		return
		
	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	
	while file_name != "":
		if file_name.ends_with(SAVE_FILE_EXTENSION):
			var slot_id: int = _extract_slot_from_filename(file_name)
			if slot_id >= 0:
				save_states[slot_id] = null # Mark as existing but not loaded
		file_name = dir.get_next()

## Extract slot ID from filename
func _extract_slot_from_filename(filename: String) -> int:
	if filename == "auto_save" + SAVE_FILE_EXTENSION:
		return AUTO_SAVE_SLOT
	
	var base_name: String = filename.get_basename()
	if base_name.begins_with("save_slot_"):
		var slot_str: String = base_name.substr(10) # Remove "save_slot_" prefix
		if slot_str.is_valid_int():
			return slot_str.to_int()
	
	return -2 # Invalid

## Get save file path for slot
func _get_save_path(slot_id: int) -> String:
	var filename: String
	if slot_id == AUTO_SAVE_SLOT:
		filename = "auto_save" + SAVE_FILE_EXTENSION
	else:
		filename = "save_slot_%d%s" % [slot_id, SAVE_FILE_EXTENSION]
	
	return SAVE_DIRECTORY + filename

## Save game to specific slot
func save_game(slot_id: int = current_save_slot) -> bool:
	if not _is_valid_slot(slot_id):
		Debugger.log_debug("Invalid save slot: %d" % slot_id)
		save_completed.emit(slot_id, false)
		return false
	
	var save_state: SaveState = _get_or_create_save_state(slot_id)
	if not save_state:
		Debugger.log_debug("Failed to create save state for slot %d" % slot_id)
		save_completed.emit(slot_id, false)
		return false
	
	update_save_state(save_state)
	
	var save_path: String = _get_save_path(slot_id)
	var error: int = ResourceSaver.save(save_state, save_path)
	
	var success: bool = error == OK
	if success:
		save_states[slot_id] = save_state
		current_save_slot = slot_id if slot_id != AUTO_SAVE_SLOT else current_save_slot
		Debugger.log_debug("Save successful to slot %d" % slot_id)
	else:
		Debugger.log_debug("Save failed to slot %d: Error %d" % [slot_id, error])
	
	save_completed.emit(slot_id, success)
	return success

## Load game from specific slot
func load_game(slot_id: int = current_save_slot) -> bool:
	if not _is_valid_slot(slot_id):
		Debugger.log_debug("Invalid load slot: %d" % slot_id)
		load_completed.emit(slot_id, false)
		return false
	
	var save_path: String = _get_save_path(slot_id)
	if not ResourceLoader.exists(save_path):
		Debugger.log_debug("Save file doesn't exist for slot %d" % slot_id)
		load_completed.emit(slot_id, false)
		return false
	
	var save_state: SaveState = _load_save_state(save_path)
	if not save_state:
		Debugger.log_debug("Failed to load save state from slot %d" % slot_id)
		load_completed.emit(slot_id, false)
		return false
	
	save_states[slot_id] = save_state
	current_save_slot = slot_id if slot_id != AUTO_SAVE_SLOT else current_save_slot
	
	apply_save_state(save_state)
	
	Debugger.log_debug("Load successful from slot %d" % slot_id)
	load_completed.emit(slot_id, true)
	return true

## Quick save to designated quick save slot
func quick_save() -> bool:
	return save_game(quick_save_slot)

## Quick load from designated quick save slot
func quick_load() -> bool:
	return load_game(quick_save_slot)

## Auto-save functionality
func _auto_save() -> void:
	if auto_save_enabled:
		save_game(AUTO_SAVE_SLOT)

## Delete save from specific slot
func delete_save(slot_id: int) -> bool:
	if not _is_valid_slot(slot_id):
		return false
	
	var save_path: String = _get_save_path(slot_id)
	if not ResourceLoader.exists(save_path):
		return false
	
	var file := FileAccess.open(save_path, FileAccess.WRITE)
	if file:
		file.close()
		DirAccess.remove_absolute(save_path)
		
		if save_states.has(slot_id):
			save_states.erase(slot_id)
		
		Debugger.log_debug("Deleted save slot %d" % slot_id)
		save_slot_deleted.emit(slot_id)
		return true
	
	return false

## Get save state for slot (load if necessary)
func get_save_state(slot_id: int) -> SaveState:
	if not _is_valid_slot(slot_id):
		return null
	
	if save_states.has(slot_id) and save_states[slot_id] != null:
		return save_states[slot_id]
	
	var save_path: String = _get_save_path(slot_id)
	if ResourceLoader.exists(save_path):
		save_states[slot_id] = _load_save_state(save_path)
		return save_states[slot_id]
	
	return null

## Check if save exists for slot
func has_save(slot_id: int) -> bool:
	if not _is_valid_slot(slot_id):
		return false
	
	var save_path: String = _get_save_path(slot_id)
	return ResourceLoader.exists(save_path)

## Get list of available save slots
func get_available_save_slots() -> Array[int]:
	var slots: Array[int] = []
	
	for slot_id in range(max_save_slots):
		if has_save(slot_id):
			slots.append(slot_id)
	
	# Check for auto-save
	if has_save(AUTO_SAVE_SLOT):
		slots.append(AUTO_SAVE_SLOT)
	
	return slots

## Get save metadata (override this method to provide custom metadata)
func get_save_metadata(slot_id: int) -> Dictionary:
	var save_state: SaveState = get_save_state(slot_id)
	if not save_state:
		return {}
	
	return {
		"slot_id": slot_id,
		"save_time": Time.get_unix_time_from_system(),
		"is_auto_save": slot_id == AUTO_SAVE_SLOT
	}

## Reset save data for specific slot
func reset_save_data(slot_id: int = current_save_slot) -> bool:
	if not _is_valid_slot(slot_id):
		return false
	
	var save_state: SaveState = SaveState.new()
	var save_path: String = _get_save_path(slot_id)
	var error: int = ResourceSaver.save(save_state, save_path)
	
	if error == OK:
		save_states[slot_id] = save_state
		Debugger.log_debug("Reset save data for slot %d" % slot_id)
		return true
	
	return false

## Validate slot ID
func _is_valid_slot(slot_id: int) -> bool:
	return slot_id == AUTO_SAVE_SLOT or (slot_id >= 0 and slot_id < max_save_slots)

## Get or create save state for slot
func _get_or_create_save_state(slot_id: int) -> SaveState:
	if save_states.has(slot_id) and save_states[slot_id] != null:
		return save_states[slot_id]
	
	var save_state: SaveState = SaveState.new()
	save_states[slot_id] = save_state
	return save_state

## Load save state from path with validation
func _load_save_state(save_path: String) -> SaveState:
	if save_path.is_empty():
		return null
	
	var loaded_resource: Resource = ResourceLoader.load(save_path)
	if not loaded_resource is SaveState:
		Debugger.log_debug("Invalid save file format: %s" % save_path)
		return null
	
	return loaded_resource as SaveState

## Apply save state to game (override in your implementation)
func apply_save_state(_save_state: SaveState) -> void:
	# Override this method to apply the loaded data to your game
	# Example:
	# GameManager.player_level = save_state.player_level
	# GameManager.player_position = save_state.player_position
	pass

## Update save state with current game data (override in your implementation)
func update_save_state(_save_state: SaveState) -> void:
	# Override this method to update the save state with current game data
	_save_state.save_timestamp = Time.get_unix_time_from_system()
	pass

## Input handling
func _input(event: InputEvent) -> void:
	pass
	# if event.is_action_pressed("quick_save"):
	# 	quick_save()
	
	# if event.is_action_pressed("quick_load"):
	# 	quick_load()
	
	# if event.is_action_pressed("reset_save_data"):
	# 	reset_save_data()
	
	# # Additional slot-based shortcuts (optional)
	# for i in range(min(10, max_save_slots)):
	# 	if event.is_action_pressed("save_slot_%d" % i):
	# 		save_game(i)
	# 	if event.is_action_pressed("load_slot_%d" % i):
	# 		load_game(i)