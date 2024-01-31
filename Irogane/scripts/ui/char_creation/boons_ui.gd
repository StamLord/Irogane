extends Control

@onready var boon_ui_node = %boons_UI
@onready var boons_list = %boons_list
@onready var boon_button_template = %boon_Button
@onready var balance_points = %balance_points
@onready var flaws_list = %flaws_list
@onready var flaw_button_template = %flaw_Button
@onready var ambitions_list = %ambition_list
@onready var ambition_button_template = %ambition_Button
@onready var boons_info_text = %boons_info_text

# Character Summary
@onready var str_val = %str_val
@onready var agi_val = %agi_val
@onready var dex_val = %dex_val
@onready var wis_val = %wis_val

@onready var stats = %stats

@onready var audio_player = %AudioPlayer
@onready var button_sound = load("res://assets/audio/ui/button_1.ogg")
@onready var button_6 = load("res://assets/audio/ui/button_6.ogg")

const BOONS = {
	"battle_tendency" : {
		"title": "Battle Hardened",
		"desc": "You a boss ass bitch",
	},
	"caligraphy_expert": {
		"title": "Caligraphy Expert",
		"desc": "read maps or something idk",
	},
	"commoners_tongue": {
		"title": "Commoner's Tongue",
		"desc": "what dat mouf do",
	},
	"courtly_eloquence": {
		"title": "Courtly Eloquence",
		"desc": "court",
	},
	"demon_whisperer": {
		"title": "Demon Whisperer",
		"desc": "court",
	},
	"fast_healer": {
		"title": "Fast Healer",
		"desc": "court",
	},
	"honor_code": {
		"title": "Honor Code",
		"desc": "court",
	},
	"extra_boon": {
		"title": "Extra Boon",
		"desc": "court",
	},
}

const FLAWS = {
	"gambling_addiction" : {
		"title": "Addiction (Gambling)",
		"desc": "You like to lose money",
	},
	"alcohol_addiction": {
		"title": "Addiction (Alcohol)",
		"desc": "davay vodka",
	},
	"bad_luck": {
		"title": "Bad Luck",
		"desc": "under ladders and black cats for you",
	},
}

const AMBITIONS = {
	"redempotion" : {
		"title": "Redemption",
		"desc": "red dead",
	},
	"fame": {
		"title": "Fame",
		"desc": "B> Fame 10k",
	},
	"enlightment": {
		"title": "Enlightment",
		"desc": "light me up",
	},
	"mastery": {
		"title": "Mastery",
		"desc": "master splinter",
	},
	"wealth": {
		"title": "Wealth",
		"desc": "cash money",
	},
	"exploration": {
		"title": "Exploration",
		"desc": "Explore",
	},
	"pleasure": {
		"title": "Pleasure",
		"desc": "over business",
	},
}

var selected_boons = {}
var selected_flaws = {}
var selected_ambition = null
var available_points = 1


func _ready():
	for boon_key in BOONS:
		var boon = BOONS[boon_key]
		var boon_button = boon_button_template.duplicate()
		boon_button.text = boon.title
		boon_button.visible = true
		boon_button.ui_button_pressed.connect(boon_button_pressed.bind(boon_key, boon_button))
		boon_button.ui_button_focused.connect(boon_button_focused.bind(boon_key))
		boons_list.add_child(boon_button)
	
	for flaw_key in FLAWS:
		var flaw = FLAWS[flaw_key]
		var flaw_button = flaw_button_template.duplicate()
		flaw_button.text = flaw.title
		flaw_button.visible = true
		flaw_button.ui_button_pressed.connect(flaw_button_pressed.bind(flaw_key, flaw_button))
		flaw_button.ui_button_focused.connect(flaw_button_focused.bind(flaw_key))
		flaws_list.add_child(flaw_button)
	
	for ambition_key in AMBITIONS:
		var ambition = AMBITIONS[ambition_key]
		var ambition_button = ambition_button_template.duplicate()
		ambition_button.text = ambition.title
		ambition_button.visible = true
		ambition_button.ui_button_pressed.connect(ambition_button_pressed.bind(ambition_key, ambition_button))
		ambition_button.ui_button_focused.connect(ambition_button_focused.bind(ambition_key))
		ambitions_list.add_child(ambition_button)
	

func update_points_balance(new_val):
	available_points = new_val
	balance_points.text = str(new_val)
	

func boon_button_focused(value):
	var boon = BOONS[value]
	boons_info_text.bbcode_text = boon.desc
	

func flaw_button_focused(value):
	var flaw = FLAWS[value]
	boons_info_text.bbcode_text = flaw.desc
	

func ambition_button_focused(value):
	var ambition = AMBITIONS[value]
	boons_info_text.bbcode_text = ambition.desc
	

func boon_button_pressed(value, boon_button):
	if value in selected_boons:
		update_points_balance(available_points + 1)
		selected_boons.erase(value)
		boon_button.get_node("selected_texture").visible = false
		audio_player.play(button_sound)
		stats.remove_boon(value)
		update_character_summary()
	else:
		if available_points > 0:
			update_points_balance(available_points - 1)
			selected_boons[value] = true
			boon_button.get_node("selected_texture").visible = true
			audio_player.play(button_sound)
			stats.add_boon(value)
			update_character_summary()
	

func flaw_button_pressed(value, flaw_button):
	if value in selected_flaws:
		if available_points > 0:
			update_points_balance(available_points - 1)
			selected_flaws.erase(value)
			flaw_button.get_node("selected_texture").visible = false
			audio_player.play(button_sound)
			stats.remove_flaw(value)
			update_character_summary()
	else:
		update_points_balance(available_points + 1)
		selected_flaws[value] = true
		flaw_button.get_node("selected_texture").visible = true
		audio_player.play(button_sound)
		stats.add_flaw(value)
		update_character_summary()
	

func ambition_button_pressed(value, ambition_button):
	if selected_ambition == null:
		selected_ambition = value
		ambition_button.get_node("selected_texture").visible = true
		audio_player.play(button_sound)
	elif selected_ambition == value:
		selected_ambition = null
		ambition_button.get_node("selected_texture").visible = false
		audio_player.play(button_sound)
	

func _on_boon_back_button_pressed():
	audio_player.play(button_6)
	owner.prev_ui_screen()
	

func _on_boon_next_button_pressed():
	var data = {
		"boons": selected_boons.keys(),
		"flaws": selected_flaws.keys(),
		"ambition": selected_ambition,
	}
	owner.load_boons(data)
	owner.next_ui_screen()
	

func _on_visibility_changed():
	update_character_summary()
	

func update_character_summary():
	if stats == null:
		return
	
	str_val.text = str(stats.strength.get_value())
	agi_val.text = str(stats.agility.get_value())
	dex_val.text = str(stats.dexterity.get_value())
	wis_val.text = str(stats.wisdom.get_value())
	
