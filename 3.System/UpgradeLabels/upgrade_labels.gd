extends Control
class_name UpgradeLabel

@export var upgrade_label_1: RichTextLabel
@export var upgrade_label_2: RichTextLabel
@export var upgrade_label_3: RichTextLabel
@export var upgrade_label_4: RichTextLabel
# @export var upgrade_label_5: RichTextLabel
# @export var upgrade_label_6: RichTextLabel
var labels: Array[RichTextLabel]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	labels = [
		upgrade_label_1,
		upgrade_label_2,
		upgrade_label_3,
		upgrade_label_4,
	]

	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
