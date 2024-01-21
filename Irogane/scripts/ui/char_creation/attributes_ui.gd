extends Control

# Stats object to change
@onready var stats = %stats

# Sound
@onready var audio_player = %AudioPlayer
@onready var focus_sound = load("res://assets/audio/ui/slow_brush_1.ogg")
@onready var click_bamboo = load("res://assets/audio/ui/bamboo_click_1.ogg")

# Buttons
@onready var focus_texture = load("res://assets/textures/ui/theme/attribute_label_texture.tres")

@onready var random_button = %attr_randomize_button
@onready var reset_button = %attr_reset_button
@onready var avail_points = %available_points

@onready var info_text = %info_text

# Data
@onready var ATTRIBUTES = {
	"strength": {
		"info": "Strength is the power behind each strike, the resilience to endure and the resolve to lift heavy burdens.\nIt affects your melee damage, critical hit chance with blunt weapons, maximum health points, carry capacity and grants the ability to lift heavy objects.",
		"points_label": %str_points,
		"label": %str_button,
		"default": 1,
	},
	"agility": {
		"info": "Agility is your ability to move as swiftly as an autumn breeze, as untiring as a steed, or as quietly as a shadow gliding across a wall.\nIt affects your stamina, stamina regeneration, fall damage, and is a prerequisite for most skills in the mobility tree.",
		"points_label": %agi_points,
		"label": %agi_button,
		"default": 1,
	},
	"dexterity": {
		"info": "Dexterity is the precision in your movements, the fineness of your blade and the subtlety of your underhanded techniques.\nIt affects your critical hit chance with slash and pierce weapons, as well as the accuracy and fire rate with ranged weapons, along with pickpocket chance.",
		"points_label": %dex_points,
		"label": %dex_button,
		"default": 1,
	},
	"wisdom": {
		"info": "Wisdom is the door to metaphysical realms, dictating the harmony within and the connection to the larger celestial powers at play.\nIt affects your Ki recharge rate, the potency of your spells, and your resistance to other spells. An  exceptionally high or low wisdom rating will change the dialogue options available to you.",
		"points_label": %wis_points,
		"label": %wis_button,
		"default": 1,
	},
}

const DEFAULT_AVAILABLE_POINTS = 10
var rng = RandomNumberGenerator.new()

var current_available_points = DEFAULT_AVAILABLE_POINTS

func _ready():
	reset_attributes()
	ATTRIBUTES.strength.label.grab_focus()
	

func reset_attributes():
	for attr_name in ATTRIBUTES:
		var attr = ATTRIBUTES[attr_name]
		update_attribute(attr_name, attr.default)
	
	update_available_points(DEFAULT_AVAILABLE_POINTS)
	

func increase_attribute_if_possible(attr_name: String):
	if current_available_points < 1 or stats[attr_name].get_unmodified() >= stats[attr_name].get_maximum_value():
		return
	
	update_available_points(current_available_points - 1)
	update_attribute(attr_name, stats[attr_name].get_unmodified() + 1)
	

func decrease_attribute_if_possible(attr_name: String):
	if stats[attr_name].get_unmodified() <= stats[attr_name].get_minimum_value():
		return
	
	update_available_points(current_available_points + 1)
	update_attribute(attr_name, stats[attr_name].get_unmodified() - 1)
	

func update_attribute(attr_name: String, new_value: int):
	stats.set_attribute([attr_name, new_value])
	var attr = ATTRIBUTES[attr_name]
	attr.points_label.text = str(new_value)
	

func update_available_points(new_value: int):
	current_available_points = new_value
	avail_points.text = str(new_value)
	

func _on_attr_randomize_button_pressed():
	audio_player.play(click_bamboo)
	
	reset_attributes()
	
	while current_available_points > 0:
		var attr_names = []
		
		for attr in ATTRIBUTES:
			attr_names.append(attr)
		
		while attr_names.size() > 0:
			var index = rng.randi_range(0, attr_names.size() - 1)
			var add_value = rng.randi_range(0, current_available_points)
			
			for i in add_value:
				increase_attribute_if_possible(attr_names[index])
	
			attr_names.remove_at(index)
	

func _on_attr_randomize_button_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		random_button.release_focus()
	

func _on_attr_reset_button_pressed():
	audio_player.play(click_bamboo)
	reset_attributes()
	

func _on_attr_reset_button_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		reset_button.release_focus()
	

func _on_str_inc_pressed():
	ATTRIBUTES.strength.label.grab_focus()
	increase_attribute_if_possible("strength")
	audio_player.play(click_bamboo)
	

func _on_str_dec_pressed():
	ATTRIBUTES.strength.label.grab_focus()
	decrease_attribute_if_possible("strength")
	audio_player.play(click_bamboo)
	

func _on_agi_dec_pressed():
	ATTRIBUTES.agility.label.grab_focus()
	decrease_attribute_if_possible("agility")
	audio_player.play(click_bamboo)
	

func _on_agi_inc_pressed():
	ATTRIBUTES.agility.label.grab_focus()
	increase_attribute_if_possible("agility")
	audio_player.play(click_bamboo)
	

func _on_dex_dec_pressed():
	ATTRIBUTES.dexterity.label.grab_focus()
	decrease_attribute_if_possible("dexterity")
	audio_player.play(click_bamboo)
	

func _on_dex_inc_pressed():
	ATTRIBUTES.dexterity.label.grab_focus()
	increase_attribute_if_possible("dexterity")
	audio_player.play(click_bamboo)
	

func _on_wis_dec_pressed():
	ATTRIBUTES.wisdom.label.grab_focus()
	decrease_attribute_if_possible("wisdom")
	audio_player.play(click_bamboo)
	

func _on_wis_inc_pressed():
	ATTRIBUTES.wisdom.label.grab_focus()
	increase_attribute_if_possible("wisdom")
	audio_player.play(click_bamboo)
	

func _on_attr_next_button_pressed():
	var attr_data = {
		"strength": { 
			"value": stats.strength.get_unmodified(),
			"modifier_dict": {},
		},
		"agility": { 
			"value": stats.agility.get_unmodified(),
			"modifier_dict": {},
		},
		"dexterity": { 
			"value": stats.dexterity.get_unmodified(),
			"modifier_dict": {},
		},
		"wisdom": { 
			"value": stats.wisdom.get_unmodified(),
			"modifier_dict": {},
		},
		"attr_points": current_available_points, 
	}
	owner.load_attributes(attr_data)
	owner.next_ui_screen()
	

func _on_attr_back_button_pressed():
	owner.prev_ui_screen()
	

func manage_gui_input(event, forward_func: Callable, backwards_func: Callable):
	if event.is_action_pressed("arrow_right"):
		audio_player.play(click_bamboo)
		forward_func.call()
		
	elif event.is_action_pressed("arrow_left"):
		audio_player.play(click_bamboo)
		backwards_func.call()
	

func _on_str_button_gui_input(event):
	manage_gui_input(event, increase_attribute_if_possible.bind("strength"), decrease_attribute_if_possible.bind("strength"))
	

func _on_agi_button_gui_input(event):
	manage_gui_input(event, increase_attribute_if_possible.bind("agility"), decrease_attribute_if_possible.bind("agility"))
	

func _on_dex_button_gui_input(event):
	manage_gui_input(event, increase_attribute_if_possible.bind("dexterity"), decrease_attribute_if_possible.bind("dexterity"))
	

func _on_wis_button_gui_input(event):
	manage_gui_input(event, increase_attribute_if_possible.bind("wisdom"), decrease_attribute_if_possible.bind("wisdom"))
	

func _on_str_button_focus_entered():
	ATTRIBUTES.strength.points_label.add_theme_color_override("font_color", Color.WHITE)
	info_text.bbcode_text = ATTRIBUTES.strength.info
	

func _on_str_button_focus_exited():
	ATTRIBUTES.strength.points_label.remove_theme_color_override("font_color")
	

func _on_agi_button_focus_entered():
	ATTRIBUTES.agility.points_label.add_theme_color_override("font_color", Color.WHITE)
	info_text.bbcode_text = ATTRIBUTES.agility.info
	

func _on_agi_button_focus_exited():
	ATTRIBUTES.agility.points_label.remove_theme_color_override("font_color")
	

func _on_dex_button_focus_entered():
	ATTRIBUTES.dexterity.points_label.add_theme_color_override("font_color", Color.WHITE)
	info_text.bbcode_text = ATTRIBUTES.dexterity.info
	

func _on_dex_button_focus_exited():
	ATTRIBUTES.dexterity.points_label.remove_theme_color_override("font_color")
	

func _on_wis_button_focus_entered():
	ATTRIBUTES.wisdom.points_label.add_theme_color_override("font_color", Color.WHITE)
	info_text.bbcode_text = ATTRIBUTES.wisdom.info
	

func _on_wis_button_focus_exited():
	ATTRIBUTES.wisdom.points_label.remove_theme_color_override("font_color")
	
