extends TextureRect

@onready var info_text = %info_text
@onready var skill_scrolls = %skill_tree_scrolls
@onready var skill_trees = %skill_tree_manager


var current_focused_skill_tree = null
var skill_trees_metadata = {}  # "skill_tree_name: { "scroll": Node, "skill_tree": Node }
var skill_selection = {}

func _ready():
	for skill_tree in skill_trees.get_children():
		skill_trees_metadata[skill_tree.skill_tree_name] = {"skill_tree": skill_tree}
	
	for skill_scroll in skill_scrolls.get_children():
		var skill_tree_name = skill_scroll.skill_name
		
		if skill_trees_metadata.has(skill_tree_name):
			skill_trees_metadata[skill_tree_name].scroll = skill_scroll
		else:
			skill_trees_metadata[skill_tree_name] = {"skill_tree": null, "scroll": skill_scroll}
		
		skill_scroll.skill_scroll_selected.connect(skill_scroll_selected)
		skill_scroll.mouse_entered.connect(skill_scroll_hovered.bind(skill_tree_name))
		skill_scroll.mouse_exited.connect(skill_scroll_unhovered)
		
		if skill_trees_metadata[skill_tree_name].skill_tree:
			var skill_tree = skill_trees_metadata[skill_tree_name].skill_tree
			skill_tree.state_updated.connect(skill_tree_state_updated)
			
			for skill in skill_tree.get_children():
				skill.mouse_entered.connect(skill_hovered.bind(skill.name, skill_tree_name))
				skill.mouse_exited.connect(skill_scroll_unhovered)
	

func skill_tree_state_updated(tree_name, skill_tree):
	skill_selection[tree_name] = skill_tree.get_learned_skills()
	

func skill_hovered(skill_name, skill_tree_name):
	var skill_data = SkillDB.get_skill(skill_tree_name, skill_name)
	
	if skill_data:
		info_text.text = skill_data.description
	

func skill_scroll_hovered(skill_tree_name):
	var skill_tree_data = SkillDB.get_skill_tree(skill_tree_name)
	if skill_tree_data:
		info_text.text = skill_tree_data.description
	

func skill_scroll_unhovered():
	if current_focused_skill_tree:
		var skill_tree_data = SkillDB.get_skill_tree(current_focused_skill_tree)
		if skill_tree_data:
			info_text.text = skill_tree_data.description
	else:
		info_text.text = ""
	

func skill_scroll_selected(skill_tree_name, skill_tree_scroll):
	if skill_tree_name == current_focused_skill_tree:
		return
	
	if current_focused_skill_tree:
		skill_trees_metadata[current_focused_skill_tree].scroll.deselect()
		
		if skill_trees_metadata[current_focused_skill_tree].skill_tree:
			var skill_tree = skill_trees_metadata[current_focused_skill_tree].skill_tree
			skill_tree.visible = false
	
	current_focused_skill_tree = skill_tree_name
	skill_tree_scroll.select()
	
	var skill_tree_data = SkillDB.get_skill_tree(skill_tree_name)
	
	if skill_tree_data:
		info_text.text = skill_tree_data.description
	
	if skill_trees_metadata[skill_tree_name].skill_tree:
		var skill_tree = skill_trees_metadata[skill_tree_name].skill_tree
		skill_tree.visible = true
	
