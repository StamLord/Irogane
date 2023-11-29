extends Node
class_name ItemDB

const ICON_PATH = "res://assets/textures/icons/"
const PICKUP_PATH = "res://assets/prefabs/pickups/"

const ITEMS = {
	"katana" : {
		"icon" : ICON_PATH + "katana.png",
		"slot" : "WEAPON",
		"type" : "SWORD",
		"pickup" : PICKUP_PATH + "pickup.tscn"
	},
	"onigiri" : {
		"icon" : ICON_PATH + "onigiri.png",
		"slot" : "CONSUMABLE",
		"type" : "CONSUMABLE",
		"pickup" : PICKUP_PATH + "pickup.tscn"
	},
	"robes" : {
		"icon" : ICON_PATH + "robes_template.png",
		"slot" : "TORSO",
		"type" : "EQUIPMENT",
		"pickup" : PICKUP_PATH + "pickup.tscn"
	},
	"godot cube" : {
		"icon" : ICON_PATH + "godot_black.png",
		"slot" : "NONE",
		"type" : "NONE",
		"pickup" : PICKUP_PATH + "pickup.tscn"
	},
	"error" : {
		"icon" : ICON_PATH + "godot_black.png",
		"slot" : "NONE",
		"type" : "NONE",
		"pickup" : PICKUP_PATH + "pickup.tscn"
	},
}

static func get_item(id):
	if id in ITEMS:
		return ITEMS[id]
	return ITEMS["error"]