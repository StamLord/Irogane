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
			},
			"whirlwind" : {
				"cost" : 1,
				"description" : "Whril",
			},
			"slowfall" : {
				"cost" : 1,
				"description" : "",
			},
			"disarm" : {
				"cost" : 1,
				"description" : "",
			},
			"mass_disarm" : {
				"cost" : 1,
				"description" : "",
			},
			"hop" : {
				"cost" : 1,
				"description" : "",
			},
			"ground_slam" : {
				"cost" : 1,
				"description" : "",
			},
			"trip" : {
				"cost" : 1,
				"description" : "",
			},
			"slider_trip" : {
				"cost" : 1,
				"description" : "",
			},
			"focused_strike" : {
				"cost" : 1,
				"description" : "",
			},
			"staff_flurry" : {
				"cost" : 1,
				"description" : "",
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
	
