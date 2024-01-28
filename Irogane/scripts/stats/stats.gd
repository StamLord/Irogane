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

var boons = []
var flaws = []

var in_battle = false
signal started_battle()
signal ended_battle()

func _ready():
	if get_owner().name == "player":
		add_debug_commands()
	

func add_boon(boon_name):
	return add_boon_or_flaw(boon_name, boons)
	

func remove_boon(boon_name):
	return remove_boon_or_flaw(boon_name, boons)
	

func add_flaw(flaw_name):
	return add_boon_or_flaw(flaw_name, flaws)
	

func remove_flaw(flaw_name):
	return remove_boon_or_flaw(flaw_name, flaws)
	

func add_boon_or_flaw(quality_name, quality_array):
	if quality_array.has(quality_name):
		return false
	
	quality_array.append(quality_name)
	
	var quality = QualityDb.get_quality(quality_name)
	if quality != null:
		for effect in quality.effects:
			var signal_name = effect.signal_name
			
			if not signal_name:
				continue
			
			var node = get_node_from_effect(effect)
			
			# Subscribe to signal
			if node != null:
				node.connect(signal_name, update_quality.bind(quality))
		
		update_quality(quality)
	
	return true
	

func remove_boon_or_flaw(quality_name, quality_array):
	if not quality_array.has(quality_name):
		return false
	
	quality_array.erase(quality_name)
	
	var quality = QualityDb.get_quality(quality_name)
	if quality != null:
		remove_quality(quality)
	
	return true
	

# Updates the quality to either add or remove the modifiers based on hooks
func update_quality(quality : Quality):
	for effect in quality.effects:
		var attribute_name = effect.attribute_name
		var modifier = effect.modifier
		var flag_name = effect.flag_name
		
		# No modifier or attribute
		if modifier == null or attribute_name == null:
			continue
		
		# No such attribute
		if not attribute_name in self or not self[attribute_name] is Attribute:
			continue
		
		var node = get_node_from_effect(effect)
		if node == null:
			continue
		
		# No flag or valid flag
		if not flag_name or validate_flag(node, flag_name):
			self[attribute_name].add_modifier(modifier)
		else:
			self[attribute_name].remove_modifier(modifier)
	

# Removes the modifiers of this quality. Use only when removing a boon/flaw!
# Use update_quality if you need to add/remove modifiers based on the hook!
func remove_quality(quality : Quality):
	for effect in quality.effects:
		var attribute_name = effect.attribute_name
		var modifier = effect.modifier
		var signal_name = effect.signal_name
		
		if signal_name:
			# Unregister from signal
			var node = get_node_from_effect(effect)
			if node != null and node.is_connected(signal_name, update_quality):
				node[signal_name].disconnect(update_quality)
		
		if modifier == null or attribute_name == null:
			continue
		
		# No such attribute
		if not attribute_name in self or not self[attribute_name] is Attribute:
			continue
		
		self[attribute_name].remove_modifier(modifier)
	

func validate_flag(node, flag_name):
	if not flag_name in node:
		return false
	
	return node[flag_name]
	

func start_battle():
	started_battle.emit()
	

func exit_battle():
	ended_battle.emit()
	

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
	level = data["level"] if "level" in data else 1
	experience = data["experience"] if "experience" in data else 0
	
	health.load_data(data["health"]) if "health" in data else 50
	stamina.load_data(data["stamina"]) if "stamina" in data else 50
	
	attr_points = data["attr_points"]
	
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
	

func get_node_from_effect(effect : Effect):
	var signal_path = effect.signal_path
	
	if signal_path == "":
		signal_path = "." # Self or root depenending on is_signal_path_local
	
	return get_node(signal_path) if effect.is_signal_path_local else get_tree().root.get_node(signal_path)
	
