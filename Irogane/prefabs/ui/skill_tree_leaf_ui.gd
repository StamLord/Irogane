@tool
extends Button
class_name Skill

signal learned(_skill_name)
signal unlearned(_skill_name)

# Skill Data
var stat_requirements = {} # attribute_name : minimum_value
var skill_requirments = [] # [skill_name, skill_name..]
var skill_tree = null
var description = ""
var cost = 1
var is_learned = false

# Line Data
@onready var lines = get_children()

enum line_origin_enum {TOP, BOTTOM, LEFT, RIGHT}
@export var line_origin = line_origin_enum.LEFT

var required_nodes = []

# Audio
@onready var audio_player = %AudioPlayer
@onready var select_sound = load("res://assets/audio/ui/fast_brush_4.ogg")
@onready var deselect_sound = load("res://assets/audio/ui/button_1_2.ogg")


func _enter_tree() -> void:
	set_notify_transform(true)
	

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		initialize()
		update_all_lines()
	

func _ready():
	initialize()
	set_button_enabled(can_learn())
	

func _pressed():
	if skill_tree == null:
		return
	
	if is_learned:
		audio_player.play(deselect_sound)
		unlearn()
		skill_tree.increase_skill_points(cost)
	elif can_learn():
		if skill_tree.is_enough_skill_points(cost):
			skill_tree.decrease_skill_points(cost)
			audio_player.play(select_sound)
			learn()
	

# Skill Logic
func can_learn(stats = null) -> bool:
	# Check skill requirements
	for req in skill_requirments:
		var skill = skill_tree.get_skill(req)
		if skill != null and not skill.is_learned:
			return false
	
	# Check stat requirements
	if stats != null:
		for stat_req in stat_requirements:
			if stats[stat_req].get_unmodified() < stat_requirements[stat_req]:
				return false
		
	return true
	

func learn():
	if is_learned:
		return 
	
	is_learned = true
	learned.emit(name)
	if skill_tree != null:
		skill_tree.update_state(name)
	set_button_theme_variation()
	

func unlearn():
	if not is_learned:
		return
	
	is_learned = false
	unlearned.emit(name)
	if skill_tree != null:
		skill_tree.update_state(name)
	set_button_theme_variation()
	

func update_state(updated_skill_name):
	# Don't update due to self
	if name == updated_skill_name:
		return
	
	# If relevant skill, change button state
	if updated_skill_name in skill_requirments:
		var _can_learn = can_learn()
		
		# Unlearn and refund points
		if is_learned and _can_learn == false:
			unlearn()
			skill_tree.increase_skill_points(cost)
		
		set_button_enabled(_can_learn)
		
		return
	

func set_button_enabled(state):
	disabled = not state
	

func set_button_theme_variation():
	theme_type_variation = "SkillLearnedButton" if is_learned else "SkillButton"
	

# Line Logic
func initialize():
	# Get parent if it's a SkillTree
	var parent = get_parent()
	if parent is SkillTree:
		skill_tree = parent
	
	var skill = SkillDB.get_skill(skill_tree.skill_tree_name, name)
	if skill != null:
		cost = skill.cost
		description = skill.description
		skill_requirments = skill.skill_requirments
		stat_requirements = skill.stat_requirements
		
	get_required_nodes()
	

func get_required_nodes():
	if skill_tree == null:
		return
	
	skill_tree.init_skill_dict()
	
	required_nodes.clear()
	for skill_name in skill_requirments:
		var skill = skill_tree.get_skill(skill_name)
		if skill != null:
			required_nodes.append(skill)
	

func update_all_lines():
	for i in range(lines.size()):
		if i < required_nodes.size():
			update_line(required_nodes[i], lines[i])
	

func update_line(node, line):
	if not node is Control or line == null:
		return
	
	var global_delta = node.global_position - global_position
	
	# Left edge of this node
	var start_pos = get_start_pos()
	# Right edge of other node
	var end_pos = Vector2(global_delta.x + node.size.x, global_delta.y + node.size.y * 0.5)
	
	# Set points
	line.clear_points()
	line.add_point(start_pos)
	line.add_point(end_pos)
	
	# Diagonal lines are not allowed
	if global_delta.y != 0:
		# Create 2 points in the center
		if line_origin == line_origin_enum.LEFT or line_origin == line_origin_enum.RIGHT:
			var mid_point = lerp(start_pos, end_pos, 0.5)
			line.add_point(Vector2(mid_point.x, start_pos.y), 1)
			line.add_point(Vector2(mid_point.x, end_pos.y), 2)
		# Create 1 point above / below
		elif line_origin == line_origin_enum.TOP or line_origin == line_origin_enum.BOTTOM:
			line.add_point(Vector2(start_pos.x, end_pos.y), 1)
	

func get_start_pos():
	if line_origin == line_origin_enum.LEFT:
		return Vector2(0, size.y * 0.5)
	elif line_origin == line_origin_enum.RIGHT:
		return Vector2(size.x, size.y * 0.5)
	elif line_origin == line_origin_enum.TOP:
		return Vector2(size.x * 0.5, 0)
	elif line_origin == line_origin_enum.BOTTOM:
		return Vector2(size.x * 0.5, size.y)
	
