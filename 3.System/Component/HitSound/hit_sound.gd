extends AudioStreamPlayer2D
class_name HitSound


func _enter_tree() -> void:
	owner.set_meta("hit_sound", self)

func _exit_tree() -> void:
	if owner:
		owner.remove_meta("hit_sound")
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


