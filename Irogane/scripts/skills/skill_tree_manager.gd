extends Control

@onready var skill_points_label = %available_skill_points

var skill_points = 3

func _ready():
	update_skill_points_label()
	

func get_skill_points():
	return skill_points
	

func decrease_skill_points(amount):
	skill_points -= amount
	skill_points = max(0, skill_points)
	update_skill_points_label()
	

func increase_skill_points(amount):
	skill_points += amount
	update_skill_points_label()
	

func update_skill_points_label():
	skill_points_label.text = str(skill_points)
	
