extends UIWindow

@onready var input = %console_inputbar
@onready var display = %console_display
@onready var suggestion_label = %suggestion_label

@onready var command_manager = get_node("/root/DebugCommandsManager")

@export var message_buffer_limit = 200
@export var command_history_limit = 100
@export var max_suggestions = 8
@export var COMMAND_NAME_COLUMN_LENGTH = 60
@export var RAY_LENGTH = 1000.0

var message_buffer: PackedStringArray = []

var command_history: PackedStringArray = []
var command_history_index: int

var found_commands: Array = []
var found_comment_index: int

var commands = {}

func print_help(args):
	if args.size() > 0:
		# specific help for 'func_name'
		var func_name = args[0]
	
		if func_name not in commands:
			push_message("[color=red]ERROR[/color]: Command not found: '%s', use 'help'" % func_name)
	
		return command_manager.get_command_usage(func_name)
		
	var help_string = "[color=green][b]------------------------------HELP------------------------------[/b][/color]\n"
	
	for command in commands: 
		var command_meta = commands[command]
	
		var command_name = "[color=#d25a35]%s[/color]" % command
	
		if command == 'help':
			command_name = str(command_name, " <command_name>")
			
		var args_detail = ""
		#for arg in command_meta.args:
		#	command_name = str(command_name, " <", arg.arg_name, ">")
		#	var arg_name = str("    -[color=#3f6a8a]", arg.arg_name,"[/color]")
		#	
		#	var spaces_to_add = COMMAND_NAME_COLUMN_LENGTH - arg_name.length()
		#	var spaces_string
		#	var spaces = []
		#	spaces.resize(spaces_to_add)
		#	spaces.fill(" ")
		#	spaces_string = "".join(spaces)
		#	args_detail = str(args_detail, arg_name, spaces_string, arg.arg_type, "  ", arg.arg_desc, "\n")
		
		var spaces_to_add = COMMAND_NAME_COLUMN_LENGTH - command_name.length()
		var spaces_string = ""
		
		if spaces_to_add > 0:
			var spaces = []
			spaces.resize(spaces_to_add)
			spaces.fill(" ")
			spaces_string = "".join(spaces)
		
		help_string = str(help_string, command_name, spaces_string, command_meta.description, "\n")
		
		# args detail
		help_string = str(help_string, args_detail)
	
	return help_string
	

func add_help_command():
	command_manager.add_command("help", print_help, [], "shows all commands, use optional <command_name> to show help for a specific command")
	

func add_clear_command():
	command_manager.add_command("clear", clear_output, [], "clears console")

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	commands = command_manager.get_all_commands()
	add_help_command()
	add_clear_command()
	

func grab_object_with_ray_cast():
		var mouse_pos = get_viewport().get_mouse_position()
		var camera3d = command_manager.main_camera
		var from = camera3d.project_ray_origin(mouse_pos)
		var to = from + camera3d.project_ray_normal(mouse_pos) * RAY_LENGTH
		var query = PhysicsRayQueryParameters3D.create(from, to)
		var space_state = camera3d.get_world_3d().direct_space_state
		var result = space_state.intersect_ray(query)
	
		if result:
			input.text = str(input.text, result.collider.get_instance_id())
	

func _process(_delta):
	if Input.is_action_just_pressed("console"):
		if visible:
			close()
		else:
			open()
			input.grab_focus()
	
	if Input.is_action_just_pressed("arrow_up"):
		if not visible:
			return
	
		if command_history_index < command_history.size() - 1:
			command_history_index += 1
			input.text = command_history[command_history_index]
			input.set_caret_column(command_history[command_history_index].length())
	
	if Input.is_action_just_pressed("arrow_down"):
		if not visible:
			return
	
		if command_history_index > 0:
			command_history_index -= 1
			input.text = command_history[command_history_index]
			input.set_caret_column(command_history[command_history_index].length())
	
	if Input.is_action_just_pressed("tab"):
		if not found_commands:
			return
	
		found_comment_index = (found_comment_index + 1) % found_commands.size()
		input.text = found_commands[found_comment_index]
		input.set_caret_column(found_commands[found_comment_index].length())
	
	if Input.is_action_just_pressed("attack_primary"):
		if not visible:
			return
		
		grab_object_with_ray_cast()
	

func open():
	input.clear()
	hide_suggestions()
	command_history_index = -1
	visible = true
	UIManager.add_window(self)
	get_tree().paused = true
	

func close():
	visible = false
	UIManager.remove_window(self)
	get_tree().paused = false
	

func push_message(msg):
	message_buffer.push_back(msg)
	if message_buffer.size() > message_buffer_limit:
		message_buffer.remove_at(0)
	
	display.bbcode_text = "\n".join(message_buffer)
	

func parse_input(input_text):
	var tokenized = input_text.split(" ", false)
	
	if tokenized.size() == 0:
		return
	
	var command = tokenized[0].to_lower()
	
	if command not in commands:
		push_message("[color=red]ERROR[/color]: Command not found: '%s', use 'help'" % command)
		return
	
	var args = []
	
	for i in range(1, tokenized.size()):
		args.push_back(tokenized[i])
	
	push_message("> %s" % input_text)
	var result = command_manager.run_command(command, args)
	
	if result:
		push_message(result)
	

func clear_output(args):
	message_buffer = []
	display.bbcode_text = "\n"
	

func _on_console_inputbar_text_submitted(new_text):
	if new_text.length() == 0:
		return
	
	parse_input(new_text)
	input.clear()
	command_history_index = -1
	command_history.insert(0, new_text)
	
	if command_history.size() > command_history_limit:
		command_history.remove_at(0)
	

func _on_console_display_focus_entered():
	input.grab_focus()
	

func try_suggest_command(new_text):
	found_commands = []
	
	for command in commands:
		if command.begins_with(new_text):
			found_commands.push_front(command)
			
	found_commands.sort()
	
	if found_commands:
		suggestion_label.visible = true
	
		if found_commands.size() > max_suggestions:
			var trunked_commands = found_commands.slice(0, max_suggestions)
			trunked_commands.push_back("...")
			trunked_commands.reverse()
			suggestion_label.text = "\n".join(trunked_commands)
		else:
			var reverse_commands = found_commands.slice(0)
			reverse_commands.reverse()
			suggestion_label.text = "\n".join(reverse_commands)
		
	else:
		suggestion_label.visible = false
		

func hide_suggestions():
	suggestion_label.visible = false
	found_commands = []
	found_comment_index = -1
	suggestion_label.text = ""
	

func _on_console_inputbar_text_changed(new_text):
	if new_text.length() == 0:
		hide_suggestions()
		return
	
	try_suggest_command(new_text)
	

func _on_suggestion_label_focus_entered():
		input.grab_focus()
	

func _on_margin_container_focus_entered():
		input.grab_focus()
	

func _on_scroll_container_focus_entered():
	input.grab_focus()


func _on_v_box_container_focus_entered():
	input.grab_focus()
