extends RefCounted
## BuiltinCommands


const Util := preload("uid://cw6s1es6yjip5")


static func register_commands() -> void:
	Console.register_command(cmd_alias, "alias", "add command alias")
	Console.register_command(cmd_aliases, "aliases", "list all aliases")
	Console.register_command(Console.clear_console, "clear", "clear console screen")
	Console.register_command(cmd_commands, "commands", "list all commands")
	Console.register_command(Console.info, "echo", "display a line of text")
	Console.register_command(cmd_eval, "eval", "evaluate an expression")
	Console.register_command(cmd_exec, "exec", "execute commands from file")
	Console.register_command(cmd_fps_max, "fps_max", "limit framerate")
	Console.register_command(cmd_fullscreen, "fullscreen", "toggle fullscreen mode")
	Console.register_command(cmd_help, "help", "show command info")
	Console.register_command(cmd_log, "log", "show recent log entries")
	Console.register_command(cmd_quit, "quit", "exit the application")
	Console.register_command(cmd_unalias, "unalias", "remove command alias")
	Console.register_command(cmd_vsync, "vsync", "adjust V-Sync")
	Console.register_command(Console.erase_history, "erase_history", "erases current history and persisted history")
	Console.add_argument_autocomplete_source("help", 1, Console.get_command_names.bind(true))


static func cmd_alias(p_alias: String, p_command: String) -> void:
	Console.info("Adding %s => %s" % [Console.format_name(p_alias), p_command])
	Console.add_alias(p_alias, p_command)


static func cmd_aliases() -> void:
	var aliases: PackedStringArray = Console.get_aliases()
	aliases.sort()
	for alias in aliases:
		var alias_argv: PackedStringArray = Console.get_alias_argv(alias)
		var cmd_name: String = alias_argv[0]
		var desc: String = Console.get_command_description(cmd_name)
		alias_argv[0] = Console.format_name(cmd_name)
		if desc.is_empty():
			Console.info(Console.format_name(alias))
		else:
			Console.info("%s is alias of: %s %s" % [
				Console.format_name(alias),
				' '.join(alias_argv),
				Console.format_tip(" // " + desc)
			])


static func cmd_commands() -> void:
	Console.info("Available commands:")
	var command_names: PackedStringArray = Console.get_command_names(false)
	for name in command_names:
		var desc: String = Console.get_command_description(name)
		var formatted_name: String = Console.format_name(name)
		Console.info(formatted_name if desc.is_empty() else "%s -- %s" % [formatted_name, desc])


static func cmd_eval(p_expression: String) -> Error:
	var _expression: Expression = Expression.new()
	var err: Error = _expression.parse(p_expression, Console.get_eval_input_names())
	if err != OK:
		Console.error(_expression.get_error_text())
		return err
	var result: Variant = _expression.execute(Console.get_eval_inputs(), Console.get_eval_base_instance())
	if not _expression.has_execute_failed():
		if result != null:
			Console.info(str(result))
		return OK
	Console.error(_expression.get_error_text())
	return ERR_SCRIPT_FAILED


static func cmd_exec(p_file: String, p_silent: bool = true) -> void:
	if not p_file.ends_with(".lcs"):
		p_file += ".lcs"
	if not FileAccess.file_exists(p_file):
		p_file = "user://" + p_file
	Console.execute_script(p_file, p_silent)


static func cmd_fps_max(p_limit: int = -1) -> void:
	if p_limit < 0:
		if Engine.max_fps == 0:
			Console.info("Framerate is unlimited.")
		else:
			Console.info("Framerate is limited to %d FPS." % Engine.max_fps)
		return

	Engine.max_fps = p_limit
	match p_limit:
		0:
			Console.info("Removing framerate limits.")
		_:
			Console.info("Limiting framerate to %d FPS." % p_limit)


static func cmd_fullscreen() -> void:
	var viewport: Window = Console.get_viewport()
	if viewport.mode == Window.MODE_WINDOWED:
		viewport.mode = Window.MODE_FULLSCREEN
		Console.info("Window switched to fullscreen mode.")
	else:
		viewport.mode = Window.MODE_WINDOWED
		Console.info("Window switched to windowed mode.")


static func cmd_help(p_command_name: String = "") -> Error:
	if p_command_name.is_empty():
		Console.print_line(Console.format_tip("Type %s to list all available commands." % Console.format_name("commands")))
		Console.print_line(Console.format_tip("Type %s to get more info about the command." % Console.format_name("help command")))
		return OK
	return Console.usage(p_command_name)


static func cmd_log(p_num_lines: int = 10) -> Error:
	var fn: String = ProjectSettings.get_setting("debug/file_logging/log_path")
	var file: FileAccess = FileAccess.open(fn, FileAccess.READ)
	if not file:
		Console.error("Can't open file: " + fn)
		return ERR_CANT_OPEN
	var contents: String = file.get_as_text()
	var lines: PackedStringArray = contents.split('\n')
	if lines.size() > 0 and lines[lines.size() - 1].strip_edges().is_empty():
		lines.remove_at(lines.size() - 1)
	var start_idx: int = maxi(lines.size() - p_num_lines, 0)
	for line in lines.slice(start_idx):
		Console.print_line(Util.bbcode_escape(line), false)
	return OK


static func cmd_quit() -> void:
	Console.get_tree().quit()


static func cmd_unalias(p_alias: String) -> void:
	if Console.has_alias(p_alias):
		Console.remove_alias(p_alias)
		Console.info("Alias removed.")
	else:
		Console.warn("Alias not found.")


static func cmd_vsync(p_mode: int = -1) -> void:
	if p_mode < 0:
		var current: int = DisplayServer.window_get_vsync_mode()
		match current:
			0:
				Console.info("V-Sync: disabled.")
			1:
				Console.info("V-Sync: enabled.")
			2:
				Console.info("Current V-Sync mode: adaptive.")
		Console.info("Adjust V-Sync mode with an argument: 0 - disabled, 1 - enabled, 2 - adaptive.")
		return

	match p_mode:
		DisplayServer.VSYNC_DISABLED:
			Console.info("Changing to disabled.")
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		DisplayServer.VSYNC_ENABLED:
			Console.info("Changing to default V-Sync.")
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
		DisplayServer.VSYNC_ADAPTIVE:
			Console.info("Changing to adaptive V-Sync.")
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ADAPTIVE)
		_:
			Console.error("Invalid mode.")
			Console.info("Acceptable modes: 0 - disabled, 1 - enabled, 2 - adaptive.")
