extends Node
class_name ItemDB

const ICON_PATH = "res://assets/textures/icons/"
const PICKUP_PATH = "res://prefabs/pickups/"

const ITEMS = {
	"katana" : {
		"icon" : ICON_PATH + "katana.png",
		"slot" : "WEAPON",
		"type" : "SWORD",
		"pickup" : preload(PICKUP_PATH + "pickup.tscn")
	},
	"onigiri" : {
		"icon" : ICON_PATH + "onigiri.png",
		"slot" : "CONSUMABLE",
		"type" : "FOOD",
		"pickup" : preload(PICKUP_PATH + "pickup.tscn")
	},
	"medicine" : {
		"icon" : ICON_PATH + "onigiri.png",
		"slot" : "CONSUMABLE",
		"type" : "MEDICINE",
		"hp_restore" : 10,
		"php_restore" : 20,
		"st_restore" : 0,
		"pst_restore" : 0,
		"inflict" : [],
		"cure" : [],
		"pickup" : preload(PICKUP_PATH + "pickup.tscn")
	},
	"shuriken" : {
		"icon" : ICON_PATH + "shuriken.png",
		"slot" : "WEAPON",
		"type" : "THROWABLE",
		"pickup" : preload(PICKUP_PATH + "weapons/shuriken.tscn")
	},
	"robes" : {
		"icon" : ICON_PATH + "robes_template.png",
		"slot" : "TORSO",
		"type" : "EQUIPMENT",
		"pickup" : preload(PICKUP_PATH + "pickup.tscn")
	},
	"godot cube" : {
		"icon" : ICON_PATH + "godot_black.png",
		"slot" : "NONE",
		"type" : "NONE",
		"pickup" : preload(PICKUP_PATH + "pickup.tscn")
	},
	"painting" : {
		"icon" : ICON_PATH + "godot_black.png",
		"slot" : "NONE",
		"type" : "NONE",
		"pickup" : preload(PICKUP_PATH + "pickup.tscn")
	},
	"big painting" : {
		"icon" : ICON_PATH + "godot_black.png",
		"slot" : "NONE",
		"type" : "NONE",
		"pickup" : preload(PICKUP_PATH + "pickup.tscn")
	},
	"error" : {
		"icon" : ICON_PATH + "godot_black.png",
		"slot" : "NONE",
		"type" : "NONE",
		"pickup" : preload(PICKUP_PATH + "pickup.tscn")
	},
	"candle_tool" : {
		"icon" : ICON_PATH + "katana.png",
		"slot" : "TOOL",
		"type" : SimpleWeaponManager.tool_type.CANDLE,
		"pickup" : preload(PICKUP_PATH + "pickup.tscn")
	},
}

static func get_item(id):
	if id in ITEMS:
		return ITEMS[id]
	return ITEMS["error"]
	

static func get_item_keys():
	return ITEMS.keys()
	
