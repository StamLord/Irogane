@tool
extends Node
var skills_db = {
	"swords": {
		"description": "Swords desc",
		"skills": {
			
		}
	},
	"staff": {
		"description": "Bo Staff action",
		"skills": {
			"guard_spin" : {
				"cost" : 1,
				"description" : "Guard Spin",
				"skill_requirments": [],
				"stat_requirements": {},
			},
			"whirlwind" : {
				"cost" : 1,
				"description" : "Whril",
				"skill_requirments": ["guard_spin"],
				"stat_requirements": {},
			},
			"slowfall" : {
				"cost" : 1,
				"description" : "",
				"skill_requirments": ["whirlwind"],
				"stat_requirements": {},
			},
			"disarm" : {
				"cost" : 1,
				"description" : "",
				"skill_requirments": [],
				"stat_requirements": {},
			},
			"mass_disarm" : {
				"cost" : 1,
				"description" : "",
				"skill_requirments": ["whirlwind", "disarm"],
				"stat_requirements": {},
			},
			"hop" : {
				"cost" : 1,
				"description" : "",
				"skill_requirments": [],
				"stat_requirements": {},
			},
			"ground_slam" : {
				"cost" : 1,
				"description" : "",
				"skill_requirments": ["hop"],
				"stat_requirements": {},
			},
			"trip" : {
				"cost" : 1,
				"description" : "",
				"skill_requirments": [],
				"stat_requirements": {},
			},
			"slider_trip" : {
				"cost" : 1,
				"description" : "",
				"skill_requirments": ["trip"],
				"stat_requirements": {},
			},
			"focused_strike" : {
				"cost" : 1,
				"description" : "",
				"skill_requirments": [],
				"stat_requirements": {},
			},
			"staff_flurry" : {
				"cost" : 1,
				"description" : "",
				"skill_requirments": ["focused_strike"],
				"stat_requirements": {},
			}
		}
	},
	"bow": {
		"description": "Bow action",
		"skills": {
			
		}
	},
	"thrown": {
		"description": "thrown action",
		"skills": {
			"triple_throw" : {
				"cost" : 1,
				"description" : "TBD",
				"skill_requirments": [],
				"stat_requirements": {},
			},
			"octo_throw" : {
				"cost" : 1,
				"description" : "TBD",
				"skill_requirments": ["triple_throw"],
				"stat_requirements": {},
			},
			"metal_shower" : {
				"cost" : 1,
				"description" : "TBD",
				"skill_requirments": ["octo_throw"],
				"stat_requirements": {},
			},
			"bouncing_shuriken" : {
				"cost" : 1,
				"description" : "TBD",
				"skill_requirments": [],
				"stat_requirements": {},
			},
			"multiplying_shuriken" : {
				"cost" : 1,
				"description" : "TBD",
				"skill_requirments": ["bouncing_shuriken"],
				"stat_requirements": {},
			},
			"burning_shuriken" : {
				"cost" : 1,
				"description" : "TBD",
				"skill_requirments": [],
				"stat_requirements": {},
			},
			"exploding_shuriken" : {
				"cost" : 1,
				"description" : "TBD",
				"skill_requirments": ["burning_shuriken", "decoy_shuriken"],
				"stat_requirements": {},
			},
			"decoy_shuriken" : {
				"cost" : 1,
				"description" : "TBD",
				"skill_requirments": [],
				"stat_requirements": {},
			},
			"body_switch" : {
				"cost" : 1,
				"description" : "TBD",
				"skill_requirments": ["decoy_shuriken", "multiplying_shuriken"],
				"stat_requirements": {},
			},
			"poison_shuriken" : {
				"cost" : 1,
				"description" : "TBD",
				"skill_requirments": [],
				"stat_requirements": {},
			},
			"draining_shuriken" : {
				"cost" : 1,
				"description" : "TBD",
				"skill_requirments": ["poison_shuriken"],
				"stat_requirements": {},
			},
			"paralysis_shuriken" : {
				"cost" : 1,
				"description" : "TBD",
				"skill_requirments": ["draining_shuriken"],
				"stat_requirements": {},
			},
		}
	},
	"unarmed": {
		"description": "unarmed action",
		"skills": {
			
		}
	},
	"mobility": {
		"description": "Mobility focuses on enhancing the agility, speed, and maneuverability of the practitioner. From nimble footwork to daring aerial maneuvers, these skills empower warriors to navigate the battlefield with unparalleled grace and efficiency.",
		"skills": {
			"dash" : {
				"cost" : 1,
				"description" : "Dash",
				"skill_requirments": [],
				"stat_requirements": {},
			},
			"after_image" : {
				"cost" : 1,
				"description" : "After image",
				"skill_requirments": ["dash"],
				"stat_requirements": {},
			},
			"double_jump" : {
				"cost" : 1,
				"description" : "Double jump",
				"skill_requirments": [],
				"stat_requirements": {},
			},
			"triple_jump" : {
				"cost" : 1,
				"description" : "Triple jump",
				"skill_requirments": ["double_jump"],
				"stat_requirements": {},
			},
			"wall_jump" : {
				"cost" : 1,
				"description" : "Wall jump",
				"skill_requirments": [],
				"stat_requirements": {},
			},
			"human_jump" : {
				"cost" : 1,
				"description" : "Human jump",
				"skill_requirments": ["wall_jump"],
				"stat_requirements": {},
			},
			"ledge_climb" : {
				"cost" : 1,
				"description" : "Ledge climb",
				"skill_requirments": [],
				"stat_requirements": {},
			},
			"wall_climb" : {
				"cost" : 1,
				"description" : "Wall climb",
				"skill_requirments": ["ledge_climb"],
				"stat_requirements": {},
			},
			"wind_stride" : {
				"cost" : 1,
				"description" : "Wind stride",
				"skill_requirments": [],
				"stat_requirements": {},
			},
			"gale_stride" : {
				"cost" : 1,
				"description" : "wind stride",
				"skill_requirments": ["wind_stride"],
				"stat_requirements": {},
			},
			"lightspeed" : {
				"cost" : 1,
				"description" : "light speed",
				"skill_requirments": ["gale_stride"],
				"stat_requirements": {},
			},
		}
	},
	"stealth": {
		"description": "stealth action",
		"skills": {
			
		}
	},
	"xaorin": {
		"description": "xaorin action",
		"skills": {
			
		}
	},
	"onmyodo": {
		"description": "Bonmyodo action",
		"skills": {
			
		}
	},
	"shugendo": {
		"description": "shengu action",
		"skills": {
			
		}
	},
}


func get_skill_tree(skill_tree_name):
	if skills_db.has(skill_tree_name):
		return skills_db[skill_tree_name]
	
	return null
	

func get_skill(skill_tree_name, skill_name):
	var skill_tree = get_skill_tree(skill_tree_name)
	
	if skill_tree:
		
		if skill_tree.skills.has(skill_name):
			return skill_tree.skills[skill_name]
	
	return null
	
