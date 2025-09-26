# class_name EventBus
extends Node

signal trait_added(component_name: String, node: Node)
signal trait_removed(component_name: String, node: Node)
signal component_added(component_name: String, node: Node)
signal component_removed(component_name: String, node: Node)
signal component_enabled(component_name: String)
signal component_disabled(component_name: String)


signal entity_enemy_destroyed(_enemy: EntityEnemy2D)


signal enemy_wave_cleared(_wave: int)


signal character_got_hut