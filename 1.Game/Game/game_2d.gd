extends Node2D
class_name Game2D


@export var projectile_player: PackedScene
@export var projectile_enemy: PackedScene

@export var asp_projectile_destroy: AudioStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect_event_bus()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func connect_event_bus() -> void:
	EventBus.projectile_destroyed.connect(_on_projectile_destroyed)
	pass


func _on_projectile_destroyed(_projectile_template: ProjectileTemplate2D, _position: Vector2, _direction: Vector2) ->void:
	if _projectile_template.custom_data.size() > 0:
		if  _projectile_template.custom_data[0] is Dictionary:
			if _projectile_template.custom_data[0].has("is_player"):

				if _projectile_template.custom_data[0].get("is_player"):
					spawn_particle(projectile_player, _position, _direction)
				else:
					spawn_particle(projectile_enemy, _position, _direction)
				
				if asp_projectile_destroy:
					asp_projectile_destroy.playing = true


func spawn_particle(_scene: PackedScene, _position: Vector2, _direction: Vector2 ) -> void:
	if !_scene: return
	var _vfx_projectile_splatter : Node = _scene.instantiate()
	if !_vfx_projectile_splatter is GPUParticles2D: return
	_vfx_projectile_splatter = _vfx_projectile_splatter as GPUParticles2D
	_direction = _direction * 1.0
	_vfx_projectile_splatter.process_material.direction = Vector3(_direction.x, _direction.y, 0)
	_vfx_projectile_splatter.global_position = _position
	_vfx_projectile_splatter.emitting = true
	ProjectileEngine.projectile_environment.add_child(_vfx_projectile_splatter)