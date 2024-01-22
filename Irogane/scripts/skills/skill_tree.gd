@tool
extends Control
class_name SkillTree

@onready var skill_tree_manager = $".."
var skills = []
var skill_dict = {}

func _ready():
	init_skill_dict()
	

func init_skill_dict():
	skills = get_children()
	
	for skill in skills:
		if skill is Skill:
			skill_dict[skill.name] = skill
	

func update_state(skill_name : String):
	for skill in skills:
		if skill is Skill:
			skill.update_state(skill_name)
	

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
