extends Control
class_name UpgradeLabel

@export var upgrade_label_1: Label
@export var upgrade_label_2: Label
@export var upgrade_label_3: Label
@export var upgrade_label_4: Label
@export var upgrade_label_5: Label
@export var upgrade_label_6: Label
var labels: Array[Label]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	labels = [
		upgrade_label_1,
		upgrade_label_2,
		upgrade_label_3,
		upgrade_label_4,
		upgrade_label_5,
		upgrade_label_6
	]

	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
