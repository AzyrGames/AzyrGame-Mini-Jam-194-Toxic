extends Node2D
class_name Main2D

const GAME_PATH: String = "uid://crbbmjtqbmfn0"
const GAME_TIME_LIMIT: float = 60*60

@export var sub_viewport: SubViewport
@export var bloody_timer: BloodyTimer
@export var game_timer: Timer
@export var upgrade_label: UpgradeLabel
@export var background: Control
@export var asp_music: AudioStreamPlayer

# @export var time_label_stuff

var game_2d: Game2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.main_2d = self
	GuiManager.switch_gui_panel(GuiManager.GUIPanel.START_SCREEN)
	EventBus.enemy_wave_cleared.connect(_on_wave_cleared)
	if asp_music:
		asp_music.playing = true
		asp_music.set("parameters/switch_to_clip", "Overkill")
	pass # Replace with function body.



func start_game() -> void:
	clear_game()
	asp_music.set("parameters/switch_to_clip", "MiniJam")

	await get_tree().create_timer(0.1667).timeout
	background.visible = false
	if !sub_viewport: return
	var _game_node : Node = Utils.instance_node(GAME_PATH)
	if !_game_node is Game2D: return
	game_2d = _game_node
	sub_viewport.add_child(_game_node)
	bloody_timer.visible = true
	bloody_timer.start_bloody_timer()
	game_timer.start(GAME_TIME_LIMIT)
	bloody_timer.wave_label.text = "WAVE\n0"

	pass



func clear_game() -> void:
	if game_2d:
		game_2d.queue_free()
	asp_music.set("parameters/switch_to_clip", "Overkill")
	
	for child in upgrade_label.get_children():
		if child is RichTextLabel:
			child.visible = false
	bloody_timer.visible = false
	bloody_timer.bloody_timer.stop()
	background.visible = true
	pass



func _on_wave_cleared(_wave: int) -> void:
	bloody_timer.wave_label.text = "WAVE\n" + str(_wave)
	pass
