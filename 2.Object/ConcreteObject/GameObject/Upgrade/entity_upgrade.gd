extends Entity2D
class_name EntityUpgrade2D




@export_range(0, 5) var index: int 

@export var positive_upgrade: UpgradeSpawner.PositiveUpgrade
@export var negative_upgrade: UpgradeSpawner.NegativeUpgrade

@export var bloody_time: float = 5

func _on_trigger_area_body_entered(body: Node2D) -> void:
	print("pickup Item: ", positive_upgrade, " -  ", negative_upgrade)
	EventBus.start_new_wave.emit()
	pass # Replace with function body.


func _on_health_depleted() -> void:
	queue_free()
	pass