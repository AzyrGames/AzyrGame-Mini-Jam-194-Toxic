extends Panel

const CommandHistory := preload("uid://dc55ouwu3ylf")

var _last_highlighted_label: Label
var _history_labels: Array[Label] = []
var _scroll_bar: VScrollBar
var _scroll_bar_width: int = 12

var _command: String = "<placeholder>"
var _history: CommandHistory
var _filter_results: PackedStringArray = []

var _display_count: int = 0
var _offset: int = 0
var _sub_index: int = 0

var _highlight_color: Color


# *** GODOT / VIRTUAL


func _init(p_history: CommandHistory) -> void:
	_history = p_history

	set_anchors_preset(Control.PRESET_FULL_RECT)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL

	var new_item: Label = Label.new()
	new_item.size_flags_vertical = Control.SIZE_SHRINK_END
	new_item.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	new_item.text = "<Placeholder>"
	add_child(new_item)
	_history_labels.append(new_item)

	_scroll_bar = VScrollBar.new()
	add_child(_scroll_bar)


func _ready() -> void:
	visibility_changed.connect(_calculate_display_count)
	_scroll_bar.scrolling.connect(_scroll_bar_scrolled)

	_highlight_color = get_theme_color(&"history_highlight_color", &"ConsoleColors")


func _input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return

	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_WHEEL_UP:
				_increment_index()
			MOUSE_BUTTON_WHEEL_DOWN:
				_decrement_index()
	elif event is InputEventKey and event.is_pressed():
		match event.keycode:
			KEY_UP:
				_increment_index()
				get_viewport().set_input_as_handled()
			KEY_DOWN:
				_decrement_index()
				get_viewport().set_input_as_handled()


# *** PUBLIC


func set_visibility(p_visible: bool) -> void:
	if not visible and p_visible:
		_search_and_filter()
	visible = p_visible


func _decrement_index() -> void:
	var current_index: int = _get_current_index()
	if current_index <= 0:
		return

	if _sub_index == 0:
		_offset -= 1
		_update_scroll_list()
	else:
		_sub_index -= 1
		_update_highlight()


func _increment_index() -> void:
	var current_index: int = _get_current_index()
	if current_index >= _filter_results.size() - 1:
		return

	if _sub_index >= _display_count - 1:
		_offset += 1
		_update_scroll_list()
	else:
		_sub_index += 1
		_update_highlight()


func get_current_text() -> String:
	if _filter_results.is_empty():
		return _command
	return _filter_results[_get_current_index()]


func search(command: String) -> void:
	if command == _command:
		return
	_command = command
	_search_and_filter()


# *** PRIVATE


func _update_scroll_list() -> void:
	for i in _display_count:
		var filter_index: int = _offset + i
		_history_labels[i].text = _filter_results[filter_index] if filter_index < _filter_results.size() else ""
	_update_scroll_bar()


func _update_highlight() -> void:
	if _sub_index < 0 or _history.size() == 0 or _filter_results.is_empty():
		return

	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = _highlight_color

	if _last_highlighted_label:
		_last_highlighted_label.remove_theme_stylebox_override("normal")

	_history_labels[_sub_index].add_theme_stylebox_override("normal", style)
	_last_highlighted_label = _history_labels[_sub_index]


func _get_current_index() -> int:
	return _offset + _sub_index


func _reset_indexes() -> void:
	_offset = 0
	_sub_index = 0


func _scroll_bar_scrolled() -> void:
	_offset = int(_scroll_bar.max_value - _display_count - _scroll_bar.value)
	_update_highlight()
	_update_scroll_list()


func _calculate_display_count() -> void:
	if not visible:
		return

	var max_y: float = size.y
	var label_size_y: float = _history_labels[0].size.y
	var label_size_x: float = size.x - _scroll_bar_width

	var display_count: int = int(max_y / label_size_y)
	if display_count > _display_count and display_count > 0:
		_display_count = display_count

	_history_labels[0].position.y = size.y - label_size_y
	_history_labels[0].size = Vector2(label_size_x, label_size_y)

	for i in range(_history_labels.size(), _display_count):
		var new_item: Label = Label.new()
		new_item.size_flags_vertical = Control.SIZE_SHRINK_END
		new_item.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		new_item.position.y = size.y - ((i + 1) * label_size_y)
		new_item.size = Vector2(label_size_x, label_size_y)
		_history_labels.append(new_item)
		add_child(new_item)

	_scroll_bar.size = Vector2(_scroll_bar_width, size.y)
	_scroll_bar.position.x = label_size_x

	_reset_history_to_beginning()


func _update_scroll_bar() -> void:
	if _display_count > 0:
		var max_size: int = _filter_results.size()
		_scroll_bar.max_value = max_size
		_scroll_bar.page = _display_count
		_scroll_bar.value = max_size - _display_count - _offset


func _reset_history_to_beginning() -> void:
	_reset_indexes()
	_update_highlight()
	_update_scroll_list()


func _search_and_filter() -> void:
	_filter_results = _history.fuzzy_match(_command)
	_reset_history_to_beginning()
