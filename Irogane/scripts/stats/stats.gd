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
		"health" : health.save(),
		"stamina" : stamina.save(),
		"attr_points" : attr_points,
		"strength" : strength.save(),
		"agility" : agility.save(),
		"dexterity" : dexterity.save(),
		"wisdom" : wisdom.save(),
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
	
