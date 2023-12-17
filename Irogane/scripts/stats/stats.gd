extends Node
class_name Stats

@export var char_name : String

@export_range(1,20) var level : int
@export var experience : int

@export var max_level = 20

@onready var health = $health
@onready var stamina = $stamina

@export var attr_points = 10

@onready var strength = $strength
@onready var agility = $agility
@onready var dexterity = $dexterity
@onready var wisdom = $wisdom

func _ready():
	add_debug_commands()
	

func save_data():
	var data = {
		"level" : level,
		"experience" : experience,
		"health" : health.save_data(),
		"stamina" : stamina.save_data(),
		"attr_points" : attr_points,
		"strength" : strength.save_data(),
		"agility" : agility.save_data(),
		"dexterity" : dexterity.save_data(),
		"wisdom" : wisdom.save_data(),
	}
	
	return data

func load_data(data):
	level = data["level"]
	experience = data["experience"]
	attr_points = data["attr_points"]
	
	health.load_data(data["health"])
	stamina.load_data(data["stamina"])
	
	strength.load_data(data["strength"])
	agility.load_data(data["agility"])
	dexterity.load_data(data["dexterity"])
	wisdom.load_data(data["wisdom"])
	

func add_debug_commands():
	DebugCommandsManager.add_command(
		"set_attr",
		set_attribute,
		 [{
				"arg_name" : "attribute",
				"arg_type" : DebugCommandsManager.ArgumentType.STRING,
				"arg_desc" : "Attribute name"
			},
			{
				"arg_name" : "value",
				"arg_type" : DebugCommandsManager.ArgumentType.INT,
				"arg_desc" : "Attribute value"
		}],
		"Set attribute to a new value within the valid range"
		)
	
	DebugCommandsManager.add_command(
		"set_hp",
		set_health,
		[{
			"arg_name" : "value",
			"arg_type" : DebugCommandsManager.ArgumentType.INT,
			"arg_desc" : "New value"
		}],
		"Sets health to a new value"
		)
		
	DebugCommandsManager.add_command(
		"set_st",
		set_stamina,
		[{
			"arg_name" : "value",
			"arg_type" : DebugCommandsManager.ArgumentType.INT,
			"arg_desc" : "New value"
		}],
		"Sets stamina to a new value"
		)
		
	DebugCommandsManager.add_command(
		"godmode",
		set_godmode,
		[{
			"arg_name" : "1/0",
			"arg_type" : DebugCommandsManager.ArgumentType.INT,
			"arg_desc" : "1: True, 0: False"
		}],
		"Sets godmode on or off"
		)
	

# args = [attribute name : String, value : Int]
func set_attribute(args : Array):
	if args[0] not in self:
		return "Invalid attribute name. Try again dumbass."
	
	self[args[0]].set_value(args[1])
	

func set_health(args : Array):
	health.set_value(args[0])
	

func set_stamina(args : Array):
	stamina.set_value(args[0])
	

func set_godmode(args: Array):
	health.set_godmode(args[0])
	stamina.set_godmode(args[0])
	
