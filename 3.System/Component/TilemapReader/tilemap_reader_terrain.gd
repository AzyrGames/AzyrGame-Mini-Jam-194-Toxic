extends TilemapReader
class_name TilemapReaderTerrain


var void_timer: Timer

@export var void_duration_ticks: int = 20
@export var safe_position_offset: Vector2


var tile_type: int
var tile_cell_custom_data: Variant
var is_after_dash: bool = false
var is_falling: bool = false
var last_safe_tile_cord: Vector2i


func _ready() -> void:
	super ()
	setup_void_tile_timer()
	safe_position_offset = position
	pass # Replace with function body.

func _physics_process(delta: float) -> void:
	check_tilemap_tile_type()


func check_tilemap_tile_type() -> void:
	tile_cell_custom_data = get_tilemap_cell_custom_data()
	if tile_cell_custom_data is int:
		tile_type = tile_cell_custom_data
	else:
		tile_type = 1
	if GameManager.game_character:
		if GameManager.game_character.is_on_moving_floor:
			tile_type = 1
	match tile_type:
		0, -1:
			if !void_timer.is_stopped():
				return
			if !GameManager.game_character:
				return
			if !GameManager.game_character.has_meta("character_hsm"):
				return
			var _character_hsm: LBHSMCharacter = GameManager.game_character.get_meta("character_hsm")
			match _character_hsm.character_limbo_state.get(_character_hsm.get_active_state()):
				_character_hsm.CharacterState.IDLE, _character_hsm.CharacterState.WALK, _character_hsm.CharacterState.RUN:
					start_void_timer(_character_hsm)
		1:
			if !void_timer.is_stopped():
				void_timer.stop()
			if !GameManager.game_character.is_on_moving_floor:
				last_safe_tile_cord = _tile_map_local

			if !GameManager.game_character: return
			if !GameManager.game_character.has_meta("character_hsm"): return
			var _character_hsm: LBHSMCharacter = GameManager.game_character.get_meta("character_hsm")
			var _current_state: LimboState = _character_hsm.get_active_state()
			if _character_hsm.character_limbo_state.get(_current_state) == _character_hsm.CharacterState.WATER:
				_current_state.dispatch(_current_state.EVENT_FINISHED)

		2:
			if !GameManager.game_character: return
			if !GameManager.game_character.has_meta("character_hsm"): return
			var _character_hsm: LBHSMCharacter = GameManager.game_character.get_meta("character_hsm")
			match _character_hsm.character_limbo_state.get(_character_hsm.get_active_state()):
				_character_hsm.CharacterState.IDLE, _character_hsm.CharacterState.WALK, _character_hsm.CharacterState.RUN:
					_character_hsm.dispatch_command(_character_hsm.DispatchCommand.WATER)


func start_void_timer(_character_hsm: LBHSMCharacter) -> void:
	if _character_hsm.dash_coyote_timer.is_stopped():
		if is_after_dash:
			make_character_fall_void()
			owner.set_collision_mask_value(5, true)
			is_after_dash = false
		else:
			void_timer.start()
	else:
		is_after_dash = true


func yell_when_falling() -> void:
	if is_falling and owner:
		if owner is EntityCharacter2D:
			owner.get_meta("player_hsm").dispatch("PLATFORM_FALL")
		elif owner is EntityEnemy2D:
			owner.remove_enemy()


func get_last_safe_position() -> Vector2:
	if !tile_map_layer:
		return global_position
	if !last_safe_tile_cord:
		return global_position
	else:
		return tile_map_layer.map_to_local(last_safe_tile_cord) - safe_position_offset


func make_character_fall_void() -> void:
	EventBus.character_falled_to_void.emit(get_last_safe_position())
	pass


func get_nearet_safe_point() -> void:
	pass


func setup_void_tile_timer() -> void:
	void_timer = Timer.new()
	void_timer.one_shot = true
	void_timer.autostart = false
	void_timer.wait_time = void_duration_ticks * Utils.get_tick_time()
	void_timer.timeout.connect(_on_void_timer_timeout)
	add_child(void_timer)


func _on_void_timer_timeout() -> void:
	make_character_fall_void()
