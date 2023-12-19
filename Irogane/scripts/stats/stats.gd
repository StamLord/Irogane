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
	
