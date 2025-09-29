extends Entity2D
class_name EntityUpgrade2D




@export_range(0, 5) var index: int 

@export var positive_upgrade: UpgradeSpawner.PositiveUpgrade
@export var negative_upgrade: UpgradeSpawner.NegativeUpgrade

@export var bloody_time: float = 5

@export var asp_entity_death: PackedScene
@export var asp_entity_upgrade: PackedScene



func process_ability(_pos_up: UpgradeSpawner.PositiveUpgrade, _neg_up: UpgradeSpawner.NegativeUpgrade) -> void:
	match _pos_up:
		UpgradeSpawner.PositiveUpgrade.POS_1:
			GameManager.entity_character.add_weapon_damage(1)
		# Shoot speed
		UpgradeSpawner.PositiveUpgrade.POS_2:
			GameManager.entity_character.add_weapon_shoot_speed(0.0501)
			pass
		# Time Gain
		UpgradeSpawner.PositiveUpgrade.POS_3:
			GameManager.main_2d.bloody_timer.add_enemy_bloody_time_bonus(0.15)
			pass
		# Time Cap
		UpgradeSpawner.PositiveUpgrade.POS_4:
			GameManager.main_2d.bloody_timer.add_bloody_time_cap(6.0)
			GameManager.main_2d.bloody_timer.add_bloody_timer_time(6)

			pass
		# Accuarcy Up
		UpgradeSpawner.PositiveUpgrade.POS_5:
			GameManager.entity_character.add_weapon_accuracy(5)
			pass
		# Mobility
		UpgradeSpawner.PositiveUpgrade.POS_6:
			GameManager.entity_character.add_mobility() 
			pass
		# Less Knockback
		UpgradeSpawner.PositiveUpgrade.POS_7:
			GameManager.entity_character.add_weapon_knock_back(-8)
			pass
	
	match _neg_up:
		UpgradeSpawner.NegativeUpgrade.NEG_1:
			GameManager.main_2d.bloody_timer.add_character_bloody_time(0.1)
			pass
		UpgradeSpawner.NegativeUpgrade.NEG_2:
			GameManager.enemy_spawner.add_enemy_hp_scale(0.1)
			pass
		UpgradeSpawner.NegativeUpgrade.NEG_3:
			GameManager.enemy_spawner.add_enemy_power_scale(0.5)
			pass
		UpgradeSpawner.NegativeUpgrade.NEG_4:
			GameManager.main_2d.bloody_timer.add_enemy_bloody_time_bonus(-0.1)
			pass
		UpgradeSpawner.NegativeUpgrade.NEG_5:
			GameManager.entity_character.add_weapon_knock_back(5)

		UpgradeSpawner.NegativeUpgrade.NEG_6:
			GameManager.main_2d.bloody_timer.add_bloody_timer_time(-(6))
			pass
		UpgradeSpawner.NegativeUpgrade.NEG_7:
			GameManager.enemy_spawner.add_enemy_speed_scale(0.1)
			pass
	pass

func _on_trigger_area_body_entered(body: Node2D) -> void:
	process_ability(positive_upgrade, negative_upgrade)
	var _ase_entity_upgrade : Node = asp_entity_upgrade.instantiate()
	if _ase_entity_upgrade is AudioStreamPlayer2D:
		_ase_entity_upgrade.global_position = global_position
		ProjectileEngine.projectile_environment.add_child(_ase_entity_upgrade)
		_ase_entity_upgrade.playing = true
	EventBus.start_new_wave.emit()
	pass # Replace with function body.


func _on_health_depleted() -> void:
	var _asp_enity_death : Node = asp_entity_death.instantiate()
	if _asp_enity_death is AudioStreamPlayer2D:
		_asp_enity_death.global_position = global_position
		ProjectileEngine.projectile_environment.add_child(_asp_enity_death)
		_asp_enity_death.playing = true
	# EventBus.entity_enemy_destroyed.emit(self)
	queue_free()

	pass
