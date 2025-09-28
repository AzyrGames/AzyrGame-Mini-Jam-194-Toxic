extends Node2D
class_name HurtFlash

@export var animation_player : AnimationPlayer
@export var health: Health
@export var hurt_sound: AudioStreamPlayer
@export var hurt_sound_2d: AudioStreamPlayer2D

func _enter_tree() -> void:
	owner.set_meta("hurt_flash", self)

func _exit_tree() -> void:
	if owner:
		owner.remove_meta("hurt_flash")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect_health()
	pass # Replace with function body.

func connect_health() -> void:
	if !health: return
	health.health_damaged.connect(_on_health_damaged)
	pass


func hitflash() -> void:
	if !animation_player: return
	if !animation_player.has_animation("hurt_flash"): return
	animation_player.play("hurt_flash")
	pass


func _on_health_damaged(_value: int) -> void:
	hitflash()
	if hurt_sound:
		hurt_sound.play()
	if hurt_sound_2d:
		hurt_sound_2d.play()
	pass

