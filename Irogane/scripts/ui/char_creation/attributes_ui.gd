extends Control

# Stats object to change
@onready var stats = %stats

# Sound
@onready var audio_player = %AudioPlayer
@onready var focus_sound = load("res://assets/audio/ui/slow_brush_1.ogg")
@onready var click_bamboo = load("res://assets/audio/ui/bamboo_click_1.ogg")
@onready var button_6 = load("res://assets/audio/ui/button_6.ogg")

# Buttons
@onready var focus_texture = load("res://assets/textures/ui/theme/attribute_label_texture.tres")

@onready var random_button = %attr_randomize_button
@onready var reset_button = %attr_reset_button
@onready var avail_points = %available_points

@onready var info_text = %info_text

@onready var preset_selection = $preset_selection
@onready var skill_trees =  %skill_trees

# Data
@onready var ATTRIBUTES = {
	"strength": {
		"info": "Strength is the power behind each strike, the resilience to endure and the resolve to lift heavy burdens.\nIt affects your melee damage, critical hit chance with blunt weapons, maximum health points, carry capacity and grants the ability to lift heavy objects.",
		"points_label": %str_points,
		"label": %str_button,
		"default": 4,
	},
	"agility": {
		"info": "Agility is your ability to move as swiftly as an autumn breeze, as untiring as a steed, or as quietly as a shadow gliding across a wall.\nIt affects your stamina, stamina regeneration, fall damage, and is a prerequisite for most skills in the mobility tree.",
		"points_label": %agi_points,
		"label": %agi_button,
		"default": 4,
	},
	"dexterity": {
		"info": "Dexterity is the precision in your movements, the fineness of your blade and the subtlety of your underhanded techniques.\nIt affects your critical hit chance with slash and pierce weapons, as well as the accuracy and fire rate with ranged weapons, along with pickpocket chance.",
		"points_label": %dex_points,
		"label": %dex_button,
		"default": 4,
	},
	"wisdom": {
		"info": "Wisdom is the door to metaphysical realms, dictating the harmony within and the connection to the larger celestial powers at play.\nIt affects your Ki recharge rate, the potency of your spells, and your resistance to other spells. An  exceptionally high or low wisdom rating will change the dialogue options available to you.",
		"points_label": %wis_points,
		"label": %wis_button,
		"default": 4,
	},
}

const PRESETS = {
	"SAMURAI PRESET" : {
		"strength" : 7,
		"agility" : 4,
		"dexterity" : 9,
		"wisdom" : 4,
	},
	"MONK PRESET" : {
		"strength" : 8,
		"agility" : 5,
		"dexterity" : 3,
		"wisdom" : 8,
	},
	"BANDIT PRESET" : {
		"strength" : 3,
		"agility" : 7,
		"dexterity" : 9,
		"wisdom" : 5,
	},
	"ONMYODO PRESET" : {
		"strength" : 3,
		"agility" : 4,
		"dexterity" : 8,
		"wisdom" : 9,
	},
	"FARMER PRESET" : {
		"strength" : 9,
		"agility" : 8,
		"dexterity" : 4,
		"wisdom" : 3,
	},
	"GEISHA PRESET" : {
		"strength" : 2,
		"agility" : 6,
		"dexterity" : 9,
		"wisdom" : 7,
	}
}

var current_preset = -1

const DEFAULT_AVAILABLE_POINTS = 8
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
	set_custom_preset()
	
	for attr in ATTRIBUTES:
		while stats[attr].get_value() != stats[attr].get_minimum_value():
			decrease_attribute_if_possible(attr)
	
	while current_available_points > 0:
		var attr_names = []
		
		for attr in ATTRIBUTES:
			attr_names.append(attr)
		
		while attr_names.size() > 0:
			if current_available_points == 0:
				return

			var index = rng.randi_range(0, attr_names.size() - 1)
			var attr_name = attr_names[index]
			var remainder_to_max = stats[attr_name].get_maximum_value() -  stats[attr_name].get_value()
			var max_points = current_available_points if current_available_points < remainder_to_max else remainder_to_max
			var add_value = rng.randi_range(0, max_points)
			
			for i in add_value:
				increase_attribute_if_possible(attr_name)

			attr_names.remove_at(index)
	

func _on_attr_randomize_button_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		random_button.release_focus()
	

func _on_attr_reset_button_pressed():
	audio_player.play(click_bamboo)
	reset_attributes()
	set_custom_preset()
	

func _on_attr_reset_button_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		reset_button.release_focus()
	

func _on_str_inc_pressed():
	ATTRIBUTES.strength.label.grab_focus()
	increase_attribute_if_possible("strength")
	set_custom_preset()
	audio_player.play(click_bamboo)
	

func _on_str_dec_pressed():
	ATTRIBUTES.strength.label.grab_focus()
	decrease_attribute_if_possible("strength")
	set_custom_preset()
	audio_player.play(click_bamboo)
	

func _on_agi_dec_pressed():
	ATTRIBUTES.agility.label.grab_focus()
	decrease_attribute_if_possible("agility")
	set_custom_preset()
	audio_player.play(click_bamboo)
	

func _on_agi_inc_pressed():
	ATTRIBUTES.agility.label.grab_focus()
	increase_attribute_if_possible("agility")
	set_custom_preset()
	audio_player.play(click_bamboo)
	

func _on_dex_dec_pressed():
	ATTRIBUTES.dexterity.label.grab_focus()
	decrease_attribute_if_possible("dexterity")
	set_custom_preset()
	audio_player.play(click_bamboo)
	

func _on_dex_inc_pressed():
	ATTRIBUTES.dexterity.label.grab_focus()
	increase_attribute_if_possible("dexterity")
	set_custom_preset()
	audio_player.play(click_bamboo)
	

func _on_wis_dec_pressed():
	ATTRIBUTES.wisdom.label.grab_focus()
	decrease_attribute_if_possible("wisdom")
	set_custom_preset()
	audio_player.play(click_bamboo)
	

func _on_wis_inc_pressed():
	ATTRIBUTES.wisdom.label.grab_focus()
	increase_attribute_if_possible("wisdom")
	set_custom_preset()
	audio_player.play(click_bamboo)
	

func _on_attr_next_button_pressed():
	audio_player.play(button_6)
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
		"skills": skill_trees.skill_selection,
	}
	owner.load_attributes(attr_data)
	owner.next_ui_screen()
	

func _on_attr_back_button_pressed():
	audio_player.play(button_6)
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
	

func apply_preset():
	if current_preset < 0 or current_preset >= PRESETS.size():
		return
	
	reset_attributes()
	
	var preset_name = PRESETS.keys()[current_preset]
	
	for attr_name in ATTRIBUTES:
		var delta = PRESETS[preset_name][attr_name] - stats[attr_name].get_unmodified()
		for i in range(abs(delta)):
			if delta > 0:
				increase_attribute_if_possible(attr_name)
			elif delta < 0:
				decrease_attribute_if_possible(attr_name)
	

func set_custom_preset():
	current_preset = -1
	preset_selection.text = "< CUSTOM PRESET >"
	

func next_preset():
	current_preset += 1
	if current_preset >= PRESETS.size():
		set_custom_preset()
	else:
		preset_selection.text = "< %s >" % PRESETS.keys()[current_preset]
		apply_preset()
	

func prev_preset():
	if current_preset == -1:
		current_preset = PRESETS.size()
	
	current_preset -= 1
	if current_preset < 0:
		set_custom_preset()
	else:
		preset_selection.text = "< %s >" % PRESETS.keys()[current_preset]
		apply_preset()
	

func _on_preset_selection_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				audio_player.play(click_bamboo)
				next_preset()
			MOUSE_BUTTON_RIGHT:
				audio_player.play(click_bamboo)
				prev_preset()
	

func _on_texture_button_pressed():
	audio_player.play(click_bamboo)
	prev_preset()
	

func _on_preset_selection_mouse_entered():
	if current_preset < 0:
		preset_selection.text = "<  CUSTOM PRESET  >"
	else:
		preset_selection.text = "<  %s  >" % PRESETS.keys()[current_preset]
	

func _on_preset_selection_mouse_exited():
	if current_preset < 0:
		preset_selection.text = "< CUSTOM PRESET >"
	else:
		preset_selection.text = "< %s >" % PRESETS.keys()[current_preset]
	
