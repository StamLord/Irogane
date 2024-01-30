extends TextureRect

@onready var info_text = %info_text

var current_focused_skill = null

@onready var SKILLS = {
	"swords": {
		"info": "cut shit with a sword",
		"skill_tree": %swords_tree,
		"button": %swords_scroll,
	},
	"staff": {
		"info": "Bo Staff action",
		"skill_tree": %staff_tree,
		"button": %staff_scroll,
	},
	"bow": {
		"info": "cut shit with a sword",
		"skill_tree": %swords_tree,
		"button": %bow_scroll,
	},
	"thrown": {
		"info": "cut shit with a sword",
		"skill_tree": %swords_tree,
		"button": %thrown_scroll,
	},
	"unarmed": {
		"info": "cut shit with a sword",
		"skill_tree": %swords_tree,
		"button": %unarmed_scroll,
	},
	"mobility": {
		"info": "Mobility focuses on enhancing the agility, speed, and maneuverability of the practitioner. From nimble footwork to daring aerial maneuvers, these skills empower warriors to navigate the battlefield with unparalleled grace and efficiency.",
		"skill_tree": %mobility_tree,
		"button": %mobility_scroll,
	},
	"stealth": {
		"info": "cut shit with a sword",
		"skill_tree": %swords_tree,
		"button": %stealth_scroll,
	},
	"xaorin": {
		"info": "cut shit with a sword",
		"skill_tree": %swords_tree,
		"button": %xaorin_scroll,
	},
	"onmyodo": {
		"info": "cut shit with a sword",
		"skill_tree": %swords_tree,
		"button": %onmyodo_scroll,
	},
	"shugendo": {
		"info": "cut shit",
		"skill_tree": %swords_tree,
		"button": %shugendo_scroll,
	},
	
}

var skill_selection = {}

func _ready():
	for skill_tree_name in SKILLS:
		var skill = SKILLS[skill_tree_name]
		skill.button.skill_selected.connect(skill_selected)
		skill.button.skill_hovered.connect(skill_hovered)
		
		skill.skill_tree.state_updated.connect(skill_tree_state_updated.bind(skill_tree_name, skill.skill_tree))
		
		for skill_selection in skill.skill_tree.get_children():
			skill_selection.mouse_entered.connect(skill_selection_hovered.bind(skill_selection.description))
	

func skill_tree_state_updated(tree_name, skill_tree):
	skill_selection[tree_name] = skill_tree.get_learned_skills()
	

func skill_selection_hovered(skill_desc):
	info_text.bbcode_text = skill_desc
	

func skill_hovered(skill_name):
	info_text.bbcode_text = SKILLS[skill_name].info
	

func skill_selected(skill_name):
	if skill_name == current_focused_skill:
		return

	if current_focused_skill:
		SKILLS[current_focused_skill].button.deselect()
		SKILLS[current_focused_skill].skill_tree.visible = false
		
	current_focused_skill = skill_name
	SKILLS[skill_name].button.select()
	info_text.bbcode_text = SKILLS[current_focused_skill].info
	SKILLS[skill_name].skill_tree.visible = true
