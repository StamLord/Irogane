extends Control

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
		"info": "Strength, the sinews of a warrior's soul, reveals the might within. It's the power behind each strike, the resilience to endure, and the essence of unyielding resolve. With heightened Strength, you embody a formidable force on the battlefield, a master of physical challenges, and a guardian of unwavering fortitude.",
		"points_label": %str_points,
		"label": %str_button,
		"default": 1,
	},
	"agility": {
		"info": "Agility, the dance of the sakura breeze, defines your grace amidst the chaos. It governs the swiftness of your steps, the height of your leaps, and the finesse of your traversal. A noble with elevated Agility moves with the fluidity of a shadow, avoiding falls with elegance and navigating obstacles as if part of a delicate kabuki performance.",
		"points_label": %agi_points,
		"label": %agi_button,
		"default": 1,
	},
	"dexterity": {
		"info": "Dexterity, the artistry of the sword, hones the precision in each movement. It guides the finesse of your blade, the mastery of slashing and piercing strikes, and the subtlety of your technique. A warrior with heightened Dexterity is a virtuoso in combat, crafting a symphony of strikes that resonate with the subtleties of a delicate ikebana arrangement.",
		"points_label": %dex_points,
		"label": %dex_button,
		"default": 1,
	},
	"wisdom": {
		"info": "Mind, the sanctuary of spiritual fortitude, opens doors to metaphysical realms. It dictates the flow of your inner energy, the potency of your spells, and the harmony of your connection to the divine. A soul with elevated Mind is a sage of the arcane, navigating the ethereal currents with the wisdom of a yamabushi on a sacred pilgrimage.",
		"points_label": %wis_points,
		"label": %wis_button,
		"default": 1,
	},
}

const DEFAULT_AVAILABLE_POINTS = 10
var rng = RandomNumberGenerator.new()

var current_available_points = DEFAULT_AVAILABLE_POINTS
var current_attribute_allocation = {}


func _ready():
	reset_attributes()
	ATTRIBUTES.strength.label.grab_focus()
	

func reset_attributes():
	current_available_points = DEFAULT_AVAILABLE_POINTS
	
	for attr_name in ATTRIBUTES:
		var attr = ATTRIBUTES[attr_name]
		current_attribute_allocation[attr_name] = attr.default
		attr.points_label.text = str(attr.default)
	
	avail_points.text = str(current_available_points)
	

func increase_attribute_if_possible(attr_name: String):
	if current_available_points < 1:
		return
	
	var attr = ATTRIBUTES[attr_name]
	current_available_points -= 1
	avail_points.text = str(current_available_points)
	current_attribute_allocation[attr_name] += 1
	attr.points_label.text = str(current_attribute_allocation[attr_name])
	

func decrease_attribute_if_possible(attr_name: String):
	if current_attribute_allocation[attr_name] < 2:
		return
	
	var attr = ATTRIBUTES[attr_name]
	current_available_points += 1
	avail_points.text = str(current_available_points)
	current_attribute_allocation[attr_name] -= 1
	attr.points_label.text = str(current_attribute_allocation[attr_name])
	

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
			"value": current_attribute_allocation.strength,
			"modifier_dict": {},
		},
		"agility": { 
			"value": current_attribute_allocation.agility,
			"modifier_dict": {},
		},
		"dexterity": { 
			"value": current_attribute_allocation.dexterity,
			"modifier_dict": {},
		},
		"wisdom": { 
			"value": current_attribute_allocation.wisdom,
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
	

func _on_str_h_box_container_mouse_entered():
	ATTRIBUTES.strength.label.grab_focus()
	

func _on_agi_h_box_container_mouse_entered():
	ATTRIBUTES.agility.label.grab_focus()
	

func _on_dex_h_box_container_mouse_entered():
	ATTRIBUTES.dexterity.label.grab_focus()
	

func _on_wis_h_box_container_mouse_entered():
	ATTRIBUTES.wisdom.label.grab_focus()
	

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
	
