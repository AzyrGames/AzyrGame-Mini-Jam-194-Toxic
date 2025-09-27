extends Node2D
class_name UpgradeSpawner

enum PositiveUpgrade {
	POS_1,
	POS_2,
	POS_3,
	POS_4,
	POS_5,
	POS_6,
	POS_7
}

enum NegativeUpgrade {
	NEG_1,
	NEG_2,
	NEG_3,
	NEG_4,
	NEG_5,
	NEG_6,
	NEG_7

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
var labels: Array[RichTextLabel]
var active_upgrade_nodes: Array[EntityUpgrade2D] = []
var active_upgrade_labels: Array[RichTextLabel] = []
var positive_upgrades: Array[PositiveUpgrade] = [
	PositiveUpgrade.POS_1,
	PositiveUpgrade.POS_2,
	PositiveUpgrade.POS_3,
	PositiveUpgrade.POS_4,
	PositiveUpgrade.POS_5,
	PositiveUpgrade.POS_6,
	PositiveUpgrade.POS_7,

]
var negative_upgrades: Array[NegativeUpgrade] = [
	NegativeUpgrade.NEG_1,
	NegativeUpgrade.NEG_2,
	NegativeUpgrade.NEG_3,
	NegativeUpgrade.NEG_4,
	NegativeUpgrade.NEG_5,
	NegativeUpgrade.NEG_6,
	NegativeUpgrade.NEG_7,
]
var positive_upgrade_name: Dictionary[PositiveUpgrade, String] = {
	PositiveUpgrade.POS_1: "Damage Up +1",
	PositiveUpgrade.POS_2: "Shoot cooldown -0.05",
	PositiveUpgrade.POS_3: "Time Gain +20%",
	PositiveUpgrade.POS_4: "Time cap +5s",
	PositiveUpgrade.POS_5: "Accuracy Up",
	PositiveUpgrade.POS_6: "Mobility Up",
	PositiveUpgrade.POS_7: "Knockback -8",


}
var negative_upgrade_name: Dictionary[NegativeUpgrade, String] = {
	NegativeUpgrade.NEG_1: "Lose time -0.1s",
	NegativeUpgrade.NEG_2: "Enemy HP +10%",
	NegativeUpgrade.NEG_3: "Enemy Power +1",
	NegativeUpgrade.NEG_4: "Time Gain -0.15%",
	NegativeUpgrade.NEG_5: "Knockback +5",
	NegativeUpgrade.NEG_6: "Lose 10s",
	NegativeUpgrade.NEG_7: "Enemy 10% faster"
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
		# spawn_marker_5,
		# spawn_marker_6
	]
	markers = markers.filter(func(marker: Marker2D) -> bool: return marker != null)
	upgrade_label = GameManager.main_2d.upgrade_label
	labels = [
		upgrade_label.upgrade_label_1,
		upgrade_label.upgrade_label_2,
		upgrade_label.upgrade_label_3,
		upgrade_label.upgrade_label_4,
		# upgrade_label.upgrade_label_5,
		# upgrade_label.upgrade_label_6
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
		var label: RichTextLabel = labels[marker_index] if marker_index < labels.size() else null

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
			var pos_text: String = "[color=40b072]" + get_positive_upgrade_text(upgrade.positive_upgrade) + ".[/color]"
			var neg_text: String = "[color=de7371]" + get_negative_upgrade_text(upgrade.negative_upgrade) + ".[/color]"
			label.text = "%s\n%s" % [pos_text, neg_text]
			label.visible = true
			active_upgrade_labels.append(label)

func get_positive_upgrade_text(upgrade: PositiveUpgrade) -> String:
	if positive_upgrade_name.has(upgrade):
		return positive_upgrade_name.get(upgrade)
	return "Unknown"

func get_negative_upgrade_text(upgrade: NegativeUpgrade) -> String:
	if upgrade == NegativeUpgrade.NEG_6:
		return "lose" + str(5 + GameManager.enemy_spawner.current_wave / 2.0) +"s"
	if negative_upgrade_name.has(upgrade):
		return negative_upgrade_name.get(upgrade)
	return "Unknown"

func _on_wave_cleared(_wave: int) -> void:
	spawn_upgrades()

func _on_start_new_wave() -> void:
	for _upgrade: EntityUpgrade2D in active_upgrade_nodes:
		_upgrade.queue_free()
	for _label: RichTextLabel in active_upgrade_labels:
		_label.visible = false
	active_upgrade_nodes.clear()
	active_upgrade_labels.clear()


func _on_upgrade_health_depleted(upgrade: EntityUpgrade2D) -> void:
	if upgrade.index < labels.size():
		var label: RichTextLabel = labels[upgrade.index]
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
