extends Node2D


@export var animation_player: AnimationPlayer


func _ready() -> void:
	connect_event_bus()


func connect_event_bus() -> void:
	EventBus.character_got_hut.connect(_on_character_got_hurt)
	EventBus.enemy_got_hut.connect(_on_enemy_got_hurt)
	EventBus.upgrade_got_hut.connect(_on_upgrade_got_hurt)

	pass


func play_animate(_name: String) -> void:
	if !animation_player: return
	if animation_player.has_animation(_name):
		animation_player.play(_name)
	pass


func _on_character_got_hurt() -> void:
	play_animate("character_got_hut")

	pass

func _on_enemy_got_hurt() -> void:
	play_animate("enemy_got_hut")

	pass

func _on_upgrade_got_hurt() -> void:
	play_animate("upgrade_got_hut")

	pass

