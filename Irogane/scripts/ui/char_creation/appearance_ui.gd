extends Control

# Nodes
@onready var character = $"../env/human_model"

# Sound
@onready var audio_player = %AudioPlayer

@onready var press_sound = load("res://assets/audio/ui/fast_brush_1_soft.ogg")
@onready var press_back_sound = load("res://assets/audio/ui/fast_brush_2_soft.ogg")
@onready var focus_sound = load("res://assets/audio/ui/slow_brush_1.ogg")
@onready var click_bamboo = load("res://assets/audio/ui/bamboo_click_1.ogg")
@onready var button_6 = load("res://assets/audio/ui/button_6.ogg")

@onready var slider_click = load("res://assets/audio/ui/slider_click.ogg")

@onready var lock_sound = load("res://assets/audio/ui/lock_1.ogg")
@onready var unlock_sound = load("res://assets/audio/ui/unlock_1.ogg")

@onready var toggle_sound = load("res://assets/audio/ui/button_5.ogg")
@onready var untoggle_sound = load("res://assets/audio/ui/button_3.ogg")

# Customization Buttons
@onready var sex_button = %sex_button
@onready var sex_lock = %sex_lock
@onready var face_button = %"Face Button"
@onready var face_lock = %face_lock
@onready var custom_skin_color_button = %CustomSkinColorButton
@onready var custom_skin_color_sliders_container = %custom_skin_color
@onready var custom_hair_color_button = %CustomHairColorButton
@onready var custom_hair_color_sliders_container = %custom_hair_color

@onready var custom_skin_color_focus = %c_skin_focus_text
@onready var custom_hair_color_focus = %c_hair_focus_text

#@onready var randomize_custom_color_checkbox = %"randomize custom color"
@onready var undo_button = %undo_button
@onready var redo_button = %redo_button
@onready var randomize_button = %randomize_button

# Textures 
@onready var unlocked_highlight_texture = load("res://assets/textures/ui/theme/unlocked_highlight_icon.png")
@onready var unlocked_texture = load("res://assets/textures/ui/theme/unlocked_icon.png")
@onready var locked_highlight_texture = load("res://assets/textures/ui/theme/locked_highlight_icon.png")
@onready var locked_texture = load("res://assets/textures/ui/theme/locked_icon.png")

# Labels
const FACE_LABEL = "FACE"

# Presets
const SKIN_COLOR_PRESETS = [
	Color(0.9412, 0.8588, 0.8275, 1),
	Color(0.9216, 0.8078, 0.7059, 1),
	Color(0.8824, 0.7647, 0.6667, 1),
	Color(0.8431, 0.7216, 0.6275, 1),
	Color(0.7451, 0.6314, 0.549, 1),
	Color(0.6275, 0.5412, 0.4706, 1),
	Color(0.5882, 0.4706, 0.3686, 1),
	Color(1, 1, 1, 1),
]

var HAIR_COLOR_PRESETS = [
	Color.html("#404033"),
	Color.html("#783f04"),
	Color.html("#ce7600"),
	Color.html("#ffc200"),
	Color.html("#ff4500"),
	Color.html("#979797"),
	Color.html("#6e4d2d"),
	Color.html("#ffffff"),
	Color.html("#5082ca"),
	Color.html("#8b74ae"),
	Color.html("#c26691"),
	Color.html("#5e9a62"),
]

# Part Configuration
@onready var MODEL_PARTS = {
	"hair": {
		"button": %"Hair Button",
		"lock": %hair_lock,
		"text": "HAIR",
		"optional": true,
	},
	"bangs": {
		"button": %"Bangs Button",
		"lock": %bangs_lock,
		"text": "BANGS",
		"optional": true,
	},
	"facial": {
		"button": %"facial button",
		"lock": %facial_lock,
		"text": "FACIAL",
		"optional": true,
	},
}

@onready var PART_COLORS = {
	"skin": {
		"button": %"Skin Color Button",
		"lock": %skin_lock,
		"text": "SKIN",
		"sliders": {
			"r": %RSkinSlider,
			"g": %GSkinSlider,
			"b": %BSkinSlider,
		},
		"labels": { 
			"r": %RSkinLabel,
			"g": %GSkinLabel,
			"b": %BSkinLabel,
		},
		"presets": SKIN_COLOR_PRESETS,
		"color_setters": ["set_skin_color"],
	},
	"hair": {
		"button": %"Hair Color Button",
		"lock": %hair_color_lock,
		"text": "HAIR COLOR",
		"sliders": {
			"r": %RHairSlider,
			"g": %GHairSlider,
			"b": %BHairSlider,
		},
		"labels": { 
			"r": %RHairLabel,
			"g": %GHairLabel,
			"b": %BHairLabel,
		},
		"presets": HAIR_COLOR_PRESETS,
		"color_setters": ["set_hair_color"],
	},
}

var rng = RandomNumberGenerator.new()

# Current selections
var current_preset_selection = {
	"skin": 0,
	"hair": 0,
}

var lock_selection = {}

var change_log = []
var redo_stack = []


# Customization logic
func _ready():
	load_default_character(true)
	sex_button.grab_focus()
	

func load_default_character(init: bool = false):
	# Load defaults
	if not init:
		character.load_defaults()
	
	update_button_selection_text(face_button, FACE_LABEL, character.default_face)
	
	# Update labels and buttons
	for part_name in MODEL_PARTS:
		var part = MODEL_PARTS[part_name]
		update_button_selection_text(part.button, part.text, character.default_selections[part_name])
		
		if "lock" in part:
			lock_selection[part_name] = false
			update_part_lock_texture(part_name)
	
	# Reset presets 
	for part_name in PART_COLORS:
		var part = PART_COLORS[part_name]
		var default_color = part.presets[0]
		
		apply_color_to_part(part_name, default_color)
		
		current_preset_selection[part_name] = 0
		update_button_selection_text(part.button, part.text, 0)
		
		lock_selection["%s_color" % part_name] = false
		update_color_lock_texture(part_name)
	
	# Unique locks
	lock_selection["sex"] = false
	update_lock_texture(sex_lock, false, sex_button.has_focus())
	lock_selection["face"] = false
	update_lock_texture(face_lock, false, sex_button.has_focus())
	

func cycle_part_variation(part: String, increment = 1):
	var model_part = MODEL_PARTS[part]
	var new_index = character.cycle_part_variation(part, increment, model_part.optional)
	update_button_selection_text(model_part.button, model_part.text, new_index)
	

func apply_color_to_part(part_name: String, color: Color):
	var part_color = PART_COLORS[part_name]
	
	part_color.sliders.r.set_value_no_signal(color.r8)
	part_color.sliders.g.set_value_no_signal(color.g8)
	part_color.sliders.b.set_value_no_signal(color.b8)
	
	part_color.labels.r.text = "%s" % color.r8
	part_color.labels.g.text = "%s" % color.g8
	part_color.labels.b.text = "%s" % color.b8
	
	for setter in part_color.color_setters:
		character.call(setter, color)
	

func cycle_color_preset(part_name: String, increment = 1):
	var part_color = PART_COLORS[part_name]
	
	var next_index = current_preset_selection[part_name] + increment
	
	if next_index == -1 or next_index == -2:
		next_index = len(part_color.presets) - 1
		
	var new_preset_selection = next_index % len(part_color.presets)
	var new_color = part_color.presets[new_preset_selection]
	
	apply_color_to_part(part_name, new_color)
	
	# These are important to have after updating the slider, as the value_changed function updates items 
	current_preset_selection[part_name] = new_preset_selection
	update_button_selection_text(part_color.button, part_color.text, new_preset_selection)
	

func update_button_selection_text(_button: Button, button_text: String, index: int):
	if index == -1:
		_button.text = "%s" % button_text
	else:
		_button.text = "%s %s" % [button_text, index]
	
	if _button.has_focus():
		_button.text = "< %s >" % _button.text
	

func refresh_button_text(part_name: String, color: bool = false):
	var part
	
	if color:
		part = PART_COLORS[part_name]
	else:
		part = MODEL_PARTS[part_name]
	
	var index
	
	if color:
		index = current_preset_selection[part_name]
	else:
		index = character.get_visible_part_index(part_name)
	
	update_button_selection_text(part.button, part.text, index)
	
	if part.button.has_focus():
		audio_player.play(focus_sound)
	

func update_part_color_slider(part_name: String, value: int, rgb_color: String):
	var part_color = PART_COLORS[part_name]
	part_color.labels[rgb_color].text = "%s" % value
	
	var new_color = Color(
		part_color.sliders.r.value / 255.0,
		part_color.sliders.g.value / 255.0,
		part_color.sliders.b.value / 255.0, 
	)
	
	new_color["%s8" % rgb_color] = value
	
	for setter in part_color.color_setters:
		character.call(setter, new_color)
	

func update_lock_texture(lock: TextureButton, locked: bool, highlight: bool):
	if locked:
		if highlight:
			lock.texture_normal = locked_highlight_texture
		else:
			lock.texture_normal = locked_texture
		lock.visible = true
	else:
		if highlight:
			lock.texture_normal = unlocked_highlight_texture
			lock.visible = true
		else:
			lock.texture_normal = unlocked_texture
			lock.visible = false
	

func update_color_lock_texture(part_name: String):
	var part_color = PART_COLORS[part_name]
	var locked = lock_selection["%s_color" % part_name]
	update_lock_texture(part_color.lock, locked, part_color.button.has_focus())
	

func update_part_lock_texture(part_name: String):
	var model_part = MODEL_PARTS[part_name]
	var locked = lock_selection[part_name]
	
	if "lock" in model_part:
		update_lock_texture(model_part.lock, locked, model_part.button.has_focus())
	

func toggle_lock(part_name: String, is_color: bool = false):
	var new_val 
	
	if is_color:
		new_val = not lock_selection["%s_color" % part_name]
		lock_selection["%s_color" % part_name] = new_val
	else:
		new_val = not lock_selection[part_name] 
		lock_selection[part_name] = new_val

	if is_color and part_name in PART_COLORS:
		update_color_lock_texture(part_name)
	elif part_name in MODEL_PARTS:
		update_part_lock_texture(part_name)
	else:
		if part_name == "sex":
			update_lock_texture(sex_lock, new_val, sex_button.has_focus())
		elif part_name == "face":
			update_lock_texture(face_lock, new_val, face_button.has_focus())
	
	if new_val:
		audio_player.play(lock_sound)
	else:
		audio_player.play(unlock_sound)
	

# Button press functions
func randomize_color():
	var r_value = rng.randf()
	var g_value = rng.randf()
	var b_value = rng.randf()
	return Color(r_value, g_value, b_value)
	

func randomize_part(part_name):
	var model_part = MODEL_PARTS[part_name]
	var new_index = character.randomize_part(part_name, model_part.optional)
	update_button_selection_text(model_part.button, model_part.text, new_index)
	return new_index
	

func _on_randomize_button_pressed():
	save_changes()
	audio_player.play(click_bamboo)
	
	if not lock_selection["sex"]:
		var sex_options = ["male", "female"]
		var sex_index = rng.randi_range(0, sex_options.size() - 1)
		var new_sex = sex_options[sex_index]
		select_sex(new_sex)
	
	if not lock_selection["face"]:
		var new_val = character.randomize_face_variation()
		update_button_selection_text(face_button, FACE_LABEL, new_val)
	
	for part_name in MODEL_PARTS:
		if "lock" in MODEL_PARTS[part_name]:
			if lock_selection[part_name]:
				continue
		
		randomize_part(part_name)
	
	for part_name in PART_COLORS:
		var part_color = PART_COLORS[part_name]
		
		if lock_selection["%s_color" % part_name]:
			continue
		
		var new_color
		var preset_selection
#		if randomize_custom_color_checkbox.button_pressed:
#			preset_selection = -1
#			new_color = randomize_color()
#		else:
		preset_selection = rng.randi_range(0, part_color.presets.size() - 1)
		new_color = part_color.presets[preset_selection]
			
		apply_color_to_part(part_name, new_color)
		# These are important to have after updating the slider, as the value_changed function updates items 
		current_preset_selection[part_name] = preset_selection
		update_button_selection_text(part_color.button, part_color.text, preset_selection)
	

func _on_r_skin_slider_value_changed(value):
	update_part_color_slider("skin", value, "r")
	

func _on_g_skin_slider_value_changed(value):
	update_part_color_slider("skin", value, "g")
	

func _on_b_skin_slider_value_changed(value):
	update_part_color_slider("skin", value, "b")
	

func _on_custom_hair_color_button_pressed():
	if custom_hair_color_button.button_pressed:
		audio_player.play(toggle_sound)
		custom_hair_color_sliders_container.show()
	else:
		audio_player.play(untoggle_sound)
		custom_hair_color_sliders_container.hide()
	

func _on_skin_color_left_arrow_pressed():
	save_changes()
	cycle_color_preset("skin", -1)
	PART_COLORS.skin.button.grab_focus()
	audio_player.play(press_back_sound)
	

func _on_hair_left_arrow_pressed():
	save_changes()
	cycle_part_variation("hair", -1)
	MODEL_PARTS.hair.button.grab_focus()
	audio_player.play(press_back_sound)
	

func _on_r_hair_slider_value_changed(value):
	update_part_color_slider("hair", value, "r")
	

func _on_g_hair_slider_value_changed(value):
	update_part_color_slider("hair", value, "g")
	

func _on_b_hair_slider_value_changed(value):
	update_part_color_slider("hair", value, "b")
	

func _on_hair_color_left_arrow_pressed():
	save_changes()
	cycle_color_preset("hair", -1)
	PART_COLORS.hair.button.grab_focus()
	audio_player.play(press_back_sound)
	

func cycle_face_selection(forward = true):
	var next_value = character.cycle_face_variation(forward)
	update_button_selection_text(face_button, FACE_LABEL, next_value)
	

func _on_face_left_arrow_pressed():
	save_changes()
	cycle_face_selection(false)
	face_button.grab_focus()
	audio_player.play(press_back_sound)
	

func _on_facial_left_arrow_pressed():
	save_changes()
	cycle_part_variation("facial", -1)
	MODEL_PARTS.facial.button.grab_focus()
	

func _on_bangs_left_arrow_pressed():
	save_changes()
	cycle_part_variation("bangs", -1)
	MODEL_PARTS.bangs.button.grab_focus()
	audio_player.play(press_back_sound)
	

func refresh_sex_text():
	if character.get_gender() == character.GENDER.MALE:
		sex_button.text = "MALE"
	elif character.get_gender() == character.GENDER.FEMALE:
		sex_button.text = "FEMALE"
	
	if sex_button.has_focus():
		sex_button.text = "< %s >" % sex_button.text
	

func select_sex(sex: String):
	if sex == "male":
		character.set_male_gender()
	elif sex == "female":
		character.set_female_gender()
	
	refresh_sex_text()
	

func toggle_sex_selection():
	if character.get_gender() == character.GENDER.MALE:
		select_sex("female")
	else:
		select_sex("male")
	
	refresh_sex_text()
	

func get_current_data():
	var data = {
		"appearance" : character.save_appearance().duplicate(true),
		"color_presets": {
			"hair": current_preset_selection["hair"],
			"skin": current_preset_selection["skin"],
		}
	}
	
	return data
	

func save_changes():
	var data = get_current_data()
	change_log.push_back(data)
	
	if change_log.size() > 100:
		change_log.pop_front()
	
	undo_button.visible = true
	redo_stack = []
	redo_button.visible = false
	

func undo_last_change():
	var curr_data = get_current_data()
	var prev_data = change_log.pop_back()
	
	if change_log.size() == 0:
		undo_button.visible = false
	
	redo_stack.push_back(curr_data)
	redo_button.visible = true
	
	apply_data(prev_data)
	

func redo_last_change():
	var curr_data = get_current_data()
	var prev_data = redo_stack.pop_back()
	
	if redo_stack.size() == 0:
		redo_button.visible = false
	
	change_log.push_back(curr_data)
	undo_button.visible = true
	
	apply_data(prev_data)
	

func apply_data(data):
	character.load_appearance(data.appearance)
	refresh_sex_text()
	current_preset_selection["skin"] = data.color_presets.skin
	update_button_selection_text(PART_COLORS.skin.button, PART_COLORS.skin.text, data.color_presets.skin)
	
	update_button_selection_text(face_button, FACE_LABEL, data.appearance.face)
	
	update_button_selection_text(MODEL_PARTS.hair.button, MODEL_PARTS.hair.text, data.appearance.parts.hair)
	
	current_preset_selection["hair"] = data.color_presets.hair
	update_button_selection_text(PART_COLORS.hair.button, PART_COLORS.hair.text, data.color_presets.hair)
	
	update_button_selection_text(MODEL_PARTS.bangs.button, MODEL_PARTS.bangs.text, data.appearance.parts.bangs)
	update_button_selection_text(MODEL_PARTS.facial.button, MODEL_PARTS.facial.text, data.appearance.parts.facial)
	
	apply_color_to_part("hair", Color(data.appearance.hair_color[0], data.appearance.hair_color[1], data.appearance.hair_color[2]))
	apply_color_to_part("skin", Color(data.appearance.skin_color[0], data.appearance.skin_color[1], data.appearance.skin_color[2]))
	

func _on_custom_skin_color_button_pressed():
	if custom_skin_color_button.button_pressed:
		audio_player.play(toggle_sound)
		custom_skin_color_sliders_container.show()
	else:
		audio_player.play(untoggle_sound)
		custom_skin_color_sliders_container.hide()
	

func manage_gui_input(event, forward_func: Callable, backwards_func: Callable):
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				audio_player.play(press_sound)
				save_changes()
				forward_func.call()
			MOUSE_BUTTON_RIGHT:
				audio_player.play(press_back_sound)
				save_changes()
				backwards_func.call()
				
	if event.is_action_pressed("arrow_right") or event.is_action_pressed("ui_accept"):
		audio_player.play(press_sound)
		save_changes()
		forward_func.call()
		
	elif event.is_action_pressed("arrow_left"):
		audio_player.play(press_back_sound)
		save_changes()
		backwards_func.call()
	

func _on_sex_button_gui_input(event):
	manage_gui_input(event, toggle_sex_selection, toggle_sex_selection)
	

func _on_skin_color_button_gui_input(event):
	manage_gui_input(event, cycle_color_preset.bind("skin"), cycle_color_preset.bind("skin", -1))
	

func _on_face_button_gui_input(event):
	manage_gui_input(event, cycle_face_selection, cycle_face_selection.bind(false))
	

func _on_hair_button_gui_input(event):
	manage_gui_input(event, cycle_part_variation.bind("hair"), cycle_part_variation.bind("hair", -1))
	

func _on_skin_lock_pressed():
	PART_COLORS.skin.button.grab_focus()
	toggle_lock("skin", true)
	

func _on_skin_color_button_focus_entered():
	update_color_lock_texture("skin")
	refresh_button_text("skin", true)
	

func _on_skin_color_button_focus_exited():
	update_color_lock_texture("skin")
	refresh_button_text("skin", true)
	

func _on_sex_lock_pressed():
	sex_button.grab_focus()
	toggle_lock("sex")
	

func _on_sex_button_focus_entered():
	update_lock_texture(sex_lock, lock_selection["sex"], sex_button.has_focus())
	refresh_sex_text()
	audio_player.play(focus_sound)
	

func _on_sex_button_focus_exited():
	update_lock_texture(sex_lock, lock_selection["sex"], sex_button.has_focus())
	refresh_sex_text()
	

func _on_face_lock_pressed():
	face_button.grab_focus()
	toggle_lock("face")


func _on_face_button_focus_entered():
	update_lock_texture(face_lock, lock_selection["face"], face_button.has_focus())
	update_button_selection_text(face_button, FACE_LABEL, character.current_face)
	audio_player.play(focus_sound)
	

func _on_face_button_focus_exited():
	update_lock_texture(face_lock, lock_selection["face"], face_button.has_focus())
	update_button_selection_text(face_button, FACE_LABEL, character.current_face)
	

func _on_hair_lock_pressed():
	MODEL_PARTS.hair.button.grab_focus()
	toggle_lock("hair")


func _on_hair_button_focus_entered():
	update_part_lock_texture("hair")
	refresh_button_text("hair", false)
	

func _on_hair_button_focus_exited():
	update_part_lock_texture("hair")
	refresh_button_text("hair", false)
	

func _on_hair_color_button_gui_input(event):
	manage_gui_input(event, cycle_color_preset.bind("hair"), cycle_color_preset.bind("hair", -1))
	

func _on_hair_color_button_focus_entered():
	update_color_lock_texture("hair")
	refresh_button_text("hair", true)
	

func _on_hair_color_button_focus_exited():
	update_color_lock_texture("hair")
	refresh_button_text("hair", true)
	

func _on_hair_color_lock_pressed():
	PART_COLORS.hair.button.grab_focus()
	toggle_lock("hair", true)
	

func _on_bangs_button_gui_input(event):
	manage_gui_input(event, cycle_part_variation.bind("bangs"), cycle_part_variation.bind("bangs", -1))
	

func _on_bangs_button_focus_entered():
	update_part_lock_texture("bangs")
	refresh_button_text("bangs", false)
	

func _on_bangs_button_focus_exited():
	update_part_lock_texture("bangs")
	refresh_button_text("bangs", false)
	

func _on_bangs_lock_pressed():
	MODEL_PARTS.bangs.button.grab_focus()
	toggle_lock("bangs")
	

func _on_facial_button_gui_input(event):
	manage_gui_input(event, cycle_part_variation.bind("facial"), cycle_part_variation.bind("facial", -1))
	

func _on_facial_button_focus_entered():
	update_part_lock_texture("facial")
	refresh_button_text("facial", false)
	

func _on_facial_button_focus_exited():
	update_part_lock_texture("facial")
	refresh_button_text("facial", false)
	

func _on_facial_lock_pressed():
	MODEL_PARTS.facial.button.grab_focus()
	toggle_lock("facial")
	

func _on_next_button_pressed():
	audio_player.play(button_6)
	owner.load_appearance(character.save_appearance())
	owner.next_ui_screen()
	

func _on_undo_button_pressed():
	audio_player.play(click_bamboo)
	undo_last_change()
	

func _on_redo_button_pressed():
	audio_player.play(click_bamboo)
	redo_last_change()
	

func _on_r_skin_slider_changed():
	audio_player.play(slider_click)
	

func _on_custom_hair_color_button_focus_entered():
	custom_hair_color_focus.visible = true
	

func _on_custom_hair_color_button_focus_exited():
	custom_hair_color_focus.visible = false
	

func _on_custom_skin_color_button_focus_entered():
	custom_skin_color_focus.visible = true
	

func _on_custom_skin_color_button_focus_exited():
	custom_skin_color_focus.visible = false
	

func slider_drag_started(part_name):
	save_changes()
	current_preset_selection[part_name] = -1
	var part_color = PART_COLORS[part_name]
	update_button_selection_text(part_color.button, part_color.text, -1)
	

func _on_r_skin_slider_drag_started():
	slider_drag_started("skin")
	

func _on_g_skin_slider_drag_started():
	slider_drag_started("skin")
	

func _on_b_skin_slider_drag_started():
	slider_drag_started("skin")
	

func _on_r_hair_slider_drag_started():
	slider_drag_started("hair")
	

func _on_g_hair_slider_drag_started():
	slider_drag_started("hair")
	

func _on_b_hair_slider_drag_started():
	slider_drag_started("hair")
	

func _on_randomize_button_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		randomize_button.release_focus()
	

func _on_undo_button_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		undo_button.release_focus()
	

func _on_redo_button_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		redo_button.release_focus()
	

func _on_custom_skin_color_button_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		custom_skin_color_button.release_focus()
	

func _on_custom_hair_color_button_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		custom_hair_color_button.release_focus()
	
