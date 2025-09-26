extends RefCounted
## Manages command history.


const HISTORY_FILE := "user://limbo_console_history.log"


var _entries: PackedStringArray = []
# var _hist_idx: int = -1
var _iterators: Array[WrappingIterator] = []
var _is_dirty: bool = false


func push_entry(p_entry: String) -> void:
	_push_entry(p_entry)
	_reset_iterators()


func _push_entry(p_entry: String) -> void:
	var idx: int = _entries.find(p_entry)
	if idx != -1:
		_entries.remove_at(idx)
	_entries.append(p_entry)
	_is_dirty = true


func get_entry(p_index: int) -> String:
	return _entries[clampi(p_index, 0, _entries.size() - 1)]


func create_iterator() -> WrappingIterator:
	var it: WrappingIterator = WrappingIterator.new(_entries)
	_iterators.append(it)
	return it


func release_iterator(p_iter: WrappingIterator) -> void:
	_iterators.erase(p_iter)


func size() -> int:
	return _entries.size()


func trim(p_max_size: int) -> void:
	if _entries.size() > p_max_size:
		_entries.resize(p_max_size)
	_reset_iterators()


func clear() -> void:
	_entries.clear()


func load(p_path: String = HISTORY_FILE) -> void:
	var file: FileAccess = FileAccess.open(p_path, FileAccess.READ)
	if not file:
		return
	while not file.eof_reached():
		var line: String = file.get_line().strip_edges()
		if not line.is_empty():
			_push_entry(line)
	file.close()
	_reset_iterators()
	_is_dirty = false


func save(p_path: String = HISTORY_FILE) -> void:
	if not _is_dirty:
		return
	var file: FileAccess = FileAccess.open(p_path, FileAccess.WRITE)
	if not file:
		push_error("Console: Failed to save console history to file: ", p_path)
		return
	for line in _entries:
		file.store_line(line)
	file.close()
	_is_dirty = false


func fuzzy_match(p_query: String) -> PackedStringArray:
	if p_query.is_empty():
		var copy: PackedStringArray = _entries.duplicate()
		copy.reverse()
		return copy

	var results: Array[Dictionary] = []
	for entry in _entries:
		var score: int = _compute_match_score(p_query.to_lower(), entry.to_lower())
		if score > 0:
			results.append({"entry": entry, "score": score})

	results.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a.score > b.score)
	var matched: PackedStringArray = []
	for rec in results:
		matched.append(rec.entry)
	return matched


func _reset_iterators() -> void:
	for it in _iterators:
		it._reassign(_entries)


static func _compute_match_score(query: String, target: String) -> int:
	if query == target:
		return 99999

	var score: int = 0
	var query_index: int = 0
	var query_len: int = query.length()
	var target_len: int = target.length()

	for i in target_len:
		if query_index < query_len and target[i] == query[query_index]:
			score += 10
			if i == 0 or target[i - 1] == " ":
				score += 5
			query_index += 1
			if query_index == query_len:
				break

	return score if query_index == query_len else 0


class WrappingIterator:
	extends RefCounted

	var _idx: int = -1
	var _entries: PackedStringArray


	func _init(p_entries: PackedStringArray) -> void:
		_entries = p_entries


	func prev() -> String:
		_idx = wrapi(_idx - 1, -1, _entries.size())
		return "" if _idx == -1 else _entries[_idx]


	func next() -> String:
		_idx = wrapi(_idx + 1, -1, _entries.size())
		return "" if _idx == -1 else _entries[_idx]


	func current() -> String:
		return "" if _idx < 0 or _idx >= _entries.size() else _entries[_idx]


	func reset() -> void:
		_idx = -1


	func _reassign(p_entries: PackedStringArray) -> void:
		_idx = -1
		_entries = p_entries
