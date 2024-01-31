extends Node
class_name SkillsDB

static var skills_db = {
	"guard_spin" : {
		"cost" : 1,
		"description" : "",
	},
	"whirlwind" : {
		"cost" : 1,
		"description" : "",
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

static func get_skill(skill_name):
	if skills_db.has(skill_name):
		return skills_db[skill_name]
	
	return null
	
