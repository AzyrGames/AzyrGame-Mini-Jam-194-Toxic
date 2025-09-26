extends TilemapReader
class_name TilemapReaderFloor

@export var concrete_audio: AudioStreamPlayer
@export var metal_audio: AudioStreamPlayer
@export var water_audio: AudioStreamPlayer

var floor_type: int = 1  # 1: concrete, 2: metal, 3: water; default concrete

func _ready() -> void:
	super._ready()

func _physics_process(delta: float) -> void:
	check_floor_type()

func check_floor_type() -> void:
	var tile_cell_custom_data: Variant = get_tilemap_cell_custom_data()
	if tile_cell_custom_data is int:
		floor_type = tile_cell_custom_data
		# Optional: clamp to valid types if needed, e.g., floor_type = clamp(floor_type, 1, 3)
	else:
		floor_type = 1  # default to concrete
