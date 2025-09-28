# class_name EventBus
extends Node

signal trait_added(component_name: String, node: Node)
signal trait_removed(component_name: String, node: Node)
signal component_added(component_name: String, node: Node)
signal component_removed(component_name: String, node: Node)
signal component_enabled(component_name: String)
signal component_disabled(component_name: String)


signal entity_enemy_destroyed(_enemy: EntityEnemy2D)

# signal enemy_wave_started(_wave: int)
signal enemy_wave_cleared(_wave: int)
signal start_new_wave()

signal upgrade_destroyed(_entity_upgrade: EntityUpgrade2D)


signal enemy_got_hut
signal character_got_hut
signal upgrade_got_hut

