extends Object
## Utility functions


static func bbcode_escape(p_text: String) -> String:
	var escaped := p_text
	escaped = escaped.replace("[", "~LB~")
	escaped = escaped.replace("]", "~RB~")
	escaped = escaped.replace("~LB~", "[lb]")
	escaped = escaped.replace("~RB~", "[rb]")
	return escaped


static func bbcode_strip(p_text: String) -> String:
	var stripped: String = ""
	var in_brackets: bool = false
	for c in p_text:
		if c == '[':
			in_brackets = true
		elif c == ']':
			in_brackets = false
		elif not in_brackets:
			stripped += c
	return stripped


static func get_method_info(p_callable: Callable) -> Dictionary:
	var method_info: Dictionary = {}
	var method_list: Array[Dictionary] = []
	if p_callable.get_object() is GDScript:
		method_list = p_callable.get_object().get_script_method_list()
	else:
		method_list = p_callable.get_object().get_method_list()
	for m in method_list:
		if m.name == p_callable.get_method():
			method_info = m
			break
	if method_info.is_empty() and p_callable.is_custom():
		var args: Array[Dictionary] = []
		for i in p_callable.get_argument_count():
			args.append({"name": "arg%d" % i, "type": TYPE_NIL})
		method_info = {
			"name": "<anonymous lambda>",
			"args": args,
			"default_args": []
		}
	return method_info


## Finds the most similar string in an array.
static func fuzzy_match_string(p_string: String, p_max_edit_distance: int, p_array: Variant) -> String:
	if typeof(p_array) != TYPE_ARRAY or p_array.is_empty():
		return ""
	var best_distance: int = int(INF)
	var best_match: String = ""
	for elem: Variant in p_array:
		var elem_str: String = str(elem)
		var dist: int = _calculate_osa_distance(p_string, elem_str)
		if dist < best_distance:
			best_distance = dist
			best_match = elem_str
	return best_match if best_distance <= p_max_edit_distance else ""


## Calculates optimal string alignment distance [br]
## See: https://en.wikipedia.org/wiki/Levenshtein_distance
static func _calculate_osa_distance(s1: String, s2: String) -> int:
	var s1_len: int = s1.length()
	var s2_len: int = s2.length()

	var row0: PackedInt32Array = PackedInt32Array()
	var row1: PackedInt32Array = PackedInt32Array()
	var row2: PackedInt32Array = PackedInt32Array()
	row0.resize(s2_len + 1)
	row1.resize(s2_len + 1)
	row2.resize(s2_len + 1)

	for i in s2_len + 1:
		row1[i] = i

	for i in s1_len:
		row2[0] = i + 1

		for j in s2_len:
			var deletion_cost: int = row1[j + 1] + 1
			var insertion_cost: int = row2[j] + 1
			var substitution_cost: int = row1[j] + (1 if s1[i] != s2[j] else 0)

			row2[j + 1] = min(deletion_cost, min(insertion_cost, substitution_cost))

			if i > 1 and j > 1 and s1[i - 1] == s2[j]:
				var transposition_cost: int = row0[j - 1] + 1
				row2[j + 1] = min(transposition_cost, row2[j + 1])

		var tmp: PackedInt32Array = row0
		row0 = row1
		row1 = row2
		row2 = tmp
	return row1[s2_len]


## Returns true, if a string is constructed of one or more space-separated valid
## command identifiers ("command" or "command sub1 sub2").
## A valid command identifier may contain only letters, digits, and underscores (_),
## and the first character may not be a digit.
static func is_valid_command_sequence(p_string: String) -> bool:
	var parts: PackedStringArray = p_string.split(' ')
	for part in parts:
		if not part.is_valid_ascii_identifier():
			return false
	return true
