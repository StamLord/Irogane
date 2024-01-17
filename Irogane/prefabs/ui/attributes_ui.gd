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

@onready var str_inc = %str_inc
@onready var str_dec = %str_dec

@onready var agi_inc = %agi_inc
@onready var agi_dec = %agi_dec

@onready var dex_inc = %dex_inc
@onready var dex_dec = %dex_dec

@onready var wis_inc = %wis_inc
@onready var wis_dec = %wis_dec

# Data
@onready var ATTRIBUTES = {
	"strength": {
		"points_label": %str_points,
		"label": %str_label,
		"default": 1,
	},
	"agility": {
		"points_label": %agi_points,
		"label": %agi_label,
		"default": 1,
	},
	"dexterity": {
		"points_label": %dex_points,
		"label": %dex_label,
		"default": 1,
	},
	"wisdom": {
		"points_label": %wis_points,
		"label": %wis_label,
		"default": 1,
	},
}
 
var rng = RandomNumberGenerator.new()
var current_focused_attr = null
const DEFAULT_AVAILABLE_POINTS = 10

var current_available_points = DEFAULT_AVAILABLE_POINTS
var current_attribute_allocation = {}


func _ready():
	reset_attributes()
	

func reset_attributes():
	current_available_points = DEFAULT_AVAILABLE_POINTS
	
	for attr_name in ATTRIBUTES:
		var attr = ATTRIBUTES[attr_name]
		current_attribute_allocation[attr_name] = attr.default
		attr.points_label.text = str(attr.default)
	
	avail_points.text = str(current_available_points)
	

func focus_attr(attr_name: String):
	var attr = ATTRIBUTES[attr_name]

	if current_focused_attr == attr:
		return
		
	audio_player.play(focus_sound)
	unfocus_current_attr()
	current_focused_attr = attr
	attr.label.add_theme_stylebox_override("normal", focus_texture)
	attr.label.add_theme_color_override("font_color", Color.WHITE)
	attr.points_label.add_theme_color_override("font_color", Color.WHITE)
	

func unfocus_current_attr():
	if current_focused_attr:
		var attr = current_focused_attr
		attr.label.remove_theme_stylebox_override("normal")
		attr.label.remove_theme_color_override("font_color")
		attr.points_label.remove_theme_color_override("font_color")
		current_focused_attr = null
	

func increase_attribute_if_possible(attr_name: String):
	focus_attr(attr_name)
	if current_available_points < 1:
		return
	
	var attr = ATTRIBUTES[attr_name]
	current_available_points -= 1
	avail_points.text = str(current_available_points)
	current_attribute_allocation[attr_name] += 1
	attr.points_label.text = str(current_attribute_allocation[attr_name])
	

func decrease_attribute_if_possible(attr_name: String):
	focus_attr(attr_name)
	if current_attribute_allocation[attr_name] < 1:
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
	
	unfocus_current_attr()
	

func _on_attr_randomize_button_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		random_button.release_focus()
	

func _on_attr_reset_button_pressed():
	audio_player.play(click_bamboo)
	unfocus_current_attr()
	reset_attributes()
	

func _on_attr_reset_button_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		reset_button.release_focus()
	

func _on_str_inc_pressed():
	increase_attribute_if_possible("strength")
	audio_player.play(click_bamboo)
	

func _on_str_inc_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		str_inc.release_focus()
	

func _on_str_dec_pressed():
	decrease_attribute_if_possible("strength")
	audio_player.play(click_bamboo)
	

func _on_str_dec_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		str_dec.release_focus()
	

func _on_agi_dec_pressed():
	decrease_attribute_if_possible("agility")
	audio_player.play(click_bamboo)
	

func _on_agi_dec_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		agi_dec.release_focus()
	

func _on_agi_inc_pressed():
	increase_attribute_if_possible("agility")
	audio_player.play(click_bamboo)
	

func _on_agi_inc_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		agi_inc.release_focus()
	

func _on_dex_dec_pressed():
	decrease_attribute_if_possible("dexterity")
	audio_player.play(click_bamboo)
	

func _on_dex_dec_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		dex_dec.release_focus()
	

func _on_dex_inc_pressed():
	increase_attribute_if_possible("dexterity")
	audio_player.play(click_bamboo)
	

func _on_dex_inc_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		dex_inc.release_focus()
	

func _on_wis_dec_pressed():
	decrease_attribute_if_possible("wisdom")
	audio_player.play(click_bamboo)
	

func _on_wis_dec_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		wis_dec.release_focus()
	

func _on_wis_inc_pressed():
	increase_attribute_if_possible("wisdom")
	audio_player.play(click_bamboo)
	

func _on_wis_inc_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		wis_inc.release_focus()
	


func _on_str_label_focus_entered():
	focus_attr("strength")
