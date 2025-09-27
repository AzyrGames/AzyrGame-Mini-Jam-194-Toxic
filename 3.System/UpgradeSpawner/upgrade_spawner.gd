extends Node2D
class_name UpgradeSpawner

enum PositiveUpgrade {
	POS_UP_1,
	POS_UP_2,
}

enum NegativeUpgrade {
	NEG_UP_1,
	NEG_UP_2,
}

@export var spawn_marker_1: Marker2D
@export var spawn_marker_2: Marker2D
@export var spawn_marker_3: Marker2D
@export var spawn_marker_4: Marker2D
@export var spawn_marker_5: Marker2D
@export var spawn_marker_6: Marker2D
@export var upgrade_scene: PackedScene

var markers: Array[Marker2D]
var upgrade_label: UpgradeLabel
var labels: Array[Label]
var active_upgrade_nodes: Array[EntityUpgrade2D] = []
var active_upgrade_labels: Array[Label] = []
var positive_upgrades: Array[PositiveUpgrade] = [
	PositiveUpgrade.POS_UP_1,
	PositiveUpgrade.POS_UP_2
]
var negative_upgrades: Array[NegativeUpgrade] = [
	NegativeUpgrade.NEG_UP_1,
	NegativeUpgrade.NEG_UP_2
]
var positive_upgrade_name: Dictionary[PositiveUpgrade, String] = {
	PositiveUpgrade.POS_UP_1: "Damage Up",
	PositiveUpgrade.POS_UP_2: "Shotspeed Up",
}
var negative_upgrade_name: Dictionary[NegativeUpgrade, String] = {
	NegativeUpgrade.NEG_UP_1: "EnemyHP up",
	NegativeUpgrade.NEG_UP_2: "Spawn Up",
}

func _ready() -> void:
	connect_event_bus()
	setup_spawner()

func setup_spawner() -> void:
	markers = [
		spawn_marker_1,
		spawn_marker_2,
		spawn_marker_3,
		spawn_marker_4,
		spawn_marker_5,
		spawn_marker_6
	]
	markers = markers.filter(func(marker: Marker2D) -> bool: return marker != null)
	upgrade_label = GameManager.main_2d.upgrade_label
	labels = [
		upgrade_label.upgrade_label_1,
		upgrade_label.upgrade_label_2,
		upgrade_label.upgrade_label_3,
		upgrade_label.upgrade_label_4,
		upgrade_label.upgrade_label_5,
		upgrade_label.upgrade_label_6
	]

func connect_event_bus() -> void:
	EventBus.enemy_wave_cleared.connect(_on_wave_cleared)
	EventBus.start_new_wave.connect(_on_start_new_wave)
	EventBus.upgrade_destroyed.connect(_upgrade_destroyed)
	

func spawn_upgrades() -> void:
	if markers.size() < 3:
		push_error("Not enough spawn markers to spawn 3 upgrades")
		return

	var player_pos: Vector2 = GameManager.entity_character.global_position

	# Create array of marker indices and their positions
	var marker_data: Array[Dictionary] = []
	for i: int in markers.size():
		marker_data.append({"index": i, "marker": markers[i]})

	# Sort by distance to player (farthest first)
	marker_data.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var dist_a: float = player_pos.distance_squared_to(a.marker.global_position)
		var dist_b: float = player_pos.distance_squared_to(b.marker.global_position)
		return dist_a > dist_b
	)

	# Get the 3 farthest markers with their original indices
	var farthest_marker_data: Array[Dictionary] = marker_data.slice(0, 3)
	for data: Dictionary in farthest_marker_data:
		var marker: Marker2D = data.marker
		var marker_index: int = data.index
		var label: Label = labels[marker_index] if marker_index < labels.size() else null

		var upgrade: EntityUpgrade2D = upgrade_scene.instantiate() as EntityUpgrade2D
		if not upgrade:
			push_error("Failed to instantiate upgrade scene")
			continue

		upgrade.global_position = marker.global_position
		upgrade.index = marker_index
		upgrade.positive_upgrade = positive_upgrades[randi() % positive_upgrades.size()]
		upgrade.negative_upgrade = negative_upgrades[randi() % negative_upgrades.size()]

		upgrade.health.health_depleted.connect(_on_upgrade_health_depleted.bind(upgrade))
		active_upgrade_nodes.append(upgrade)
		add_child(upgrade)

		if label:
			var pos_text: String = get_positive_upgrade_text(upgrade.positive_upgrade)
			var neg_text: String = get_negative_upgrade_text(upgrade.negative_upgrade)
			label.text = "%s\n%s" % [pos_text, neg_text]
			label.visible = true
			active_upgrade_labels.append(label)

func get_positive_upgrade_text(upgrade: PositiveUpgrade) -> String:
	if positive_upgrade_name.has(upgrade):
		return positive_upgrade_name.get(upgrade)
	return "Unknown"

func get_negative_upgrade_text(upgrade: NegativeUpgrade) -> String:
	if negative_upgrade_name.has(upgrade):
		return negative_upgrade_name.get(upgrade)
	return "Unknown"

func _on_wave_cleared(_wave: int) -> void:
	spawn_upgrades()

func _on_start_new_wave() -> void:
	for _upgrade: EntityUpgrade2D in active_upgrade_nodes:
		_upgrade.queue_free()
	for _label: Label in active_upgrade_labels:
		_label.visible = false
	active_upgrade_nodes.clear()
	active_upgrade_labels.clear()


func _on_upgrade_health_depleted(upgrade: EntityUpgrade2D) -> void:
	if upgrade.index < labels.size():
		var label: Label = labels[upgrade.index]
		if label and label in active_upgrade_labels:
			label.visible = false
			active_upgrade_labels.erase(label)
	EventBus.upgrade_destroyed.emit(upgrade)



func _upgrade_destroyed(_entity_upgrade: EntityUpgrade2D) -> void:
	if _entity_upgrade in active_upgrade_nodes:
		active_upgrade_nodes.erase(_entity_upgrade)
	if active_upgrade_nodes.size() <= 0:
		EventBus.start_new_wave.emit()
	pass
