@tool
extends Control
class_name SkillTree

@export var skill_tree_name: String
@onready var skill_tree_manager = $".."
var skill_dict = {}

signal state_updated(skill_tree_name, skill_tree)

func _ready():
	init_skill_dict()
	

func init_skill_dict():
	for child in get_children():
		if child is Skill:
			skill_dict[child.name] = child
	

func update_state(skill_name : String):
	for skill in skill_dict:
		skill_dict[skill].update_state(skill_name)
	
	state_updated.emit(skill_tree_name, self)
	

func get_skill(skill_name : String):
	if skill_dict.has(skill_name):
		return skill_dict[skill_name]
	return null
	

func is_enough_skill_points(skill_cost):
	return skill_tree_manager.get_skill_points() >= skill_cost
	

func decrease_skill_points(amount):
	skill_tree_manager.decrease_skill_points(amount)
	

func increase_skill_points(amount):
	skill_tree_manager.increase_skill_points(amount)
	

# Return an array of skill names (strings)
func get_learned_skills():
	var learned = []
	for skill in skill_dict:
		if skill_dict[skill].is_learned:
			learned.append(skill)
	
	return learned
	

func save_data():
	return {"learned": get_learned_skills()}
	

func load_data(data):
	if data.has("learned") == false:
		return
	
	for skill_name in data["learned"]:
		if skill_dict.has(skill_name):
			skill_dict[skill_name].learn()
	
