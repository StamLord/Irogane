extends Node

enum ArgumentType {
	INT,
	FLOAT,
	STRING
}

const ArgumentTypeNameMapper = {
	ArgumentType.INT: "INT",
	ArgumentType.FLOAT: "FLOAT",
	ArgumentType.STRING: "STRING",
}

@export var COMMAND_NAME_COLUMN_LENGTH = 65
# command_ name: {
#	"function": Callable (args) -> result_string	- function to run, prints 'result_string' to console
# 	"description: String							- description of command
# 	"args": [										- array of dictionaries represeting args
#		{ 
#			"arg_name": 	String
#			"arg_type": 	ArgumentType enum
#			"arg_desc": 	String, argument description, optional
#		}
#	]
var commands_db = {}

func get_command_usage(command_name: String):
	if command_name not in commands_db:
		return "[color=red]ERROR[/color]: Command not found: '%s', use 'help'" % command_name
	
	var args_string = ""
	
	for arg_meta in commands_db[command_name].args:
		var arg_string = " <%s>" % arg_meta.arg_name
		args_string = str(args_string, arg_string)
	
	var usage_contents = "[i][color=green]Usage[/color]: %s%s[/i]" % [command_name, args_string]
	
	var spaces_to_add = COMMAND_NAME_COLUMN_LENGTH - usage_contents.length()
	var spaces_string = ""

	if spaces_to_add > 0:
		var spaces = []
		spaces.resize(spaces_to_add)
		spaces.fill(" ")
		spaces_string = "".join(spaces)
			
	return str(usage_contents, spaces_string, commands_db[command_name].description)
	

func add_command(command_name: String, function: Callable, args: Array, description: String = ""):
	for arg in args:
		if "arg_name" not in arg:
			print("Error adding command '%s' , missing 'arg_name' in argument dict under args array" % command_name)
			return

		if "arg_type" not in arg:
			print("Error adding command '%s' , missing 'arg_type' for argument '%s'" % [command_name, arg["arg_name"]])
			return
	
	commands_db[command_name] = {
		"function": function,
		"description": description,
		"args": args,
	}
	

func run_command(command_name: String, args: PackedStringArray):
	if command_name not in commands_db:
		return "[color=red]ERROR[/color]: Command not found: '%s', this should not happen" % command_name

	var command_meta = commands_db[command_name]
	
	if command_meta.args.size() > args.size():
		return "[color=red]ERROR[/color]: missing arguments, '%s' requires %s arguments but got %s\n%s" %  [command_name, command_meta.args.size(), args.size(), get_command_usage(command_name)]
	
	var casted_args = []
	
	for i in range(command_meta.args.size()):
		var arg_meta = command_meta.args[i]
		var actual_arg = args[i]
	
		match(arg_meta.arg_type):
			ArgumentType.FLOAT:
				if not args[i].is_valid_float():
					return "[color=red]ERROR[/color]: bad argument type for argument '%s', expected: 'float'" % arg_meta.arg_name
				
				actual_arg = args[i].to_float()
			ArgumentType.INT:
				if not args[i].is_valid_int():
					return "[color=red]ERROR[/color]: bad argument type for argument '%s', expected: 'int'" % arg_meta.arg_name
				
				actual_arg = args[i].to_int()
		
		casted_args.push_back(actual_arg)
		
	if command_name == "help":
		casted_args = args
	
	var command_function = command_meta.function
	return command_function.call(casted_args)
	

func get_all_commands():
	return commands_db
	
