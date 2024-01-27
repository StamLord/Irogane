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

func _ready():
	for skill_name in SKILLS:
		var skill = SKILLS[skill_name]
		skill.button.skill_selected.connect(skill_selected)
		skill.button.skill_hovered.connect(skill_hovered)
	

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
