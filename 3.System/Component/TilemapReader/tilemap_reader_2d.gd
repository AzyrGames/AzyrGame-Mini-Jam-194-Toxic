extends Area2D
class_name TilemapReader

@export var tilemap_custom_data: String

var tile_map_layer: TileMapLayer
var tile_map_rid: RID

var _tile_map_local: Vector2i
var _cell_tile_data: TileData

func _ready() -> void:
	setup_signal()


func setup_signal() -> void:
	body_shape_entered.connect(_on_body_shape_entered)
	body_shape_exited.connect(_on_body_shape_exited)


func get_tilemap_cell_custom_data() -> Variant:
	if not tile_map_layer:
		return null
	_tile_map_local = tile_map_layer.local_to_map(global_position)
	_cell_tile_data = tile_map_layer.get_cell_tile_data(_tile_map_local)
	
	if not _cell_tile_data or not _cell_tile_data.has_custom_data(tilemap_custom_data):
		return null
	
	return _cell_tile_data.get_custom_data(tilemap_custom_data)



func _on_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if !body is TileMapLayer:
		return
	if !owner:
		return
	tile_map_rid = body_rid
	tile_map_layer = body

func _on_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	pass
