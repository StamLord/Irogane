extends UIWindow

# Nodes
@onready var character = $"../env/male_model"
@onready var camera = %Camera3D
@onready var node_to_rotate = $"../env/male_model/rotate_around"

# Sound
@onready var audio_player = %AudioPlayer

@onready var press_sound = load("res://assets/audio/ui/fast_brush_1_soft.ogg")
@onready var press_back_sound = load("res://assets/audio/ui/fast_brush_2_soft.ogg")
@onready var focus_sound = load("res://assets/audio/ui/slow_brush_1.ogg")
@onready var click_bamboo = load("res://assets/audio/ui/bamboo_click_1.ogg")

@onready var slider_click = load("res://assets/audio/ui/slider_click.ogg")

@onready var lock_sound = load("res://assets/audio/ui/lock_1.ogg")
@onready var unlock_sound = load("res://assets/audio/ui/unlock_1.ogg")

@onready var toggle_sound = load("res://assets/audio/ui/button_5.ogg")
@onready var untoggle_sound = load("res://assets/audio/ui/button_3.ogg")

# Customization Buttons
@onready var char_name = %LineEdit
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

@onready var reset_camera_button = %ResetCamera

@onready var available_points_label = %availablepointsLabel

@onready var undo_button = %undo_button
@onready var redo_button = %redo_button
@onready var randomize_button = %randomize_button

# Textures 
@onready var unlocked_highlight_texture =  load("res://assets/textures/ui/theme/unlocked_highlight_icon.png")
@onready var unlocked_texture =  load("res://assets/textures/ui/theme/unlocked_icon.png")
@onready var locked_highlight_texture =  load("res://assets/textures/ui/theme/locked_highlight_icon.png")
@onready var locked_texture =  load("res://assets/textures/ui/theme/locked_icon.png")

# Labels
const R_LABEL = "R"
const G_LABEL = "G"
const B_LABEL = "B"
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

const HAIR_COLOR_PRESETS = [
	Color(0.25, 0.25, 0.18, 1),
	Color(0.6039, 0.2941, 0, 1),
	Color(0.8118, 0.4667, 0, 1),
	Color(1, 0.7608, 0, 1),
	Color(1, 0.2745, 0, 1),
	Color(0.5882, 0.5882, 0.5882, 1),
	Color(1, 1, 1, 1),
]


# Part Configuration
@onready var MODEL_PARTS = {
	#"head": {
	#	"button": %"Head Button",
	#	"text": "Head Style",
	#	"optional": false,
	#},
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
#	"mask": {
#		"button": %"mask button",
#		"text": "MASK",
#		"optional": true,
#	},
#	"top": {
#		"button": %"Top Button",
#		"text": "TOP",
#		"optional": true,
#	},
#	"bottom": {
#		"button": %"Pants Button",
#		"text": "BOTTOM",
#		"optional": true,
#	},
#	"shoes": {
#		"button": %"shoes button",
#		"text": "SHOES",
#		"optional": true,
#	},
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


# Attributes
@onready var ATTRIBUTES = {
	"strength": {
		"spin": %strSpinBox,
		"default": 1,
	},
	"agility": {
		"spin": %agiSpinBox,
		"default": 1,
	},
	"dexterity": {
		"spin": %dexSpinBox,
		"default": 1,
	},
	"wisdom": {
		"spin": %wisSpinBox,
		"default": 1,
	},
}

const DEFAULT_AVAILABLE_POINTS = 10
const POINTS_TEXT = "Available Points"

# Current selections
var current_preset_selection = {
	"skin": 0,
	"hair": 0,
}

var lock_selection = {}

var current_attribute_allocation = {}
var current_sex_selection = "male"
var current_available_points = DEFAULT_AVAILABLE_POINTS

var rng = RandomNumberGenerator.new()

const preset_filename = "preset.chr"

var change_log = []
var redo_stack = []

# Customization logic
func _ready():
	UIManager.add_window(self)
	load_default_character(true)
	reset_attributes()
	sex_button.grab_focus()
	
	default_camera_position = camera.position
	default_node_rotation = node_to_rotate.rotation_degrees
	

func reset_attributes():
	current_available_points = DEFAULT_AVAILABLE_POINTS
	available_points_label.text = "%s %s" % [POINTS_TEXT, DEFAULT_AVAILABLE_POINTS]
	
	for attr_name in ATTRIBUTES:
		var attr = ATTRIBUTES[attr_name]
		current_attribute_allocation[attr_name] = attr.default
		attr.spin.set_value_no_signal(attr.default)
	

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
#	const color_label = {
#		"r": R_LABEL,
#		"g": G_LABEL,
#		"b": B_LABEL,
#	}
	
	var part_color = PART_COLORS[part_name]
	#part_color.labels[rgb_color].text = "%s %s" % [color_label[rgb_color], value]
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
	

# Attributes Logic
func reduce_available_points(points: int):
	current_available_points -= points
	available_points_label.text = "%s %s" % [POINTS_TEXT, current_available_points]
	

func try_set_attribute_value(attr_name: String, points: int):
	var attr = ATTRIBUTES[attr_name]
	var current_value = current_attribute_allocation[attr_name]
	var points_to_add = points - current_value
	
	if points_to_add > current_available_points:
		points_to_add = current_available_points
	
	reduce_available_points(points_to_add)
	current_attribute_allocation[attr_name] += points_to_add
	attr.spin.set_value_no_signal(current_attribute_allocation[attr_name])
	

# Camera and character movement logic
var default_camera_position = Vector3(0, 1.8, 2)
var default_node_rotation = Vector3(0, 22, 0) 

const SCROLL_SPEED = 0.1

const MAX_SCROLL = 0.0
const MIN_SCROLL = -2.0
const MAX_VERTICAL_MOVE = 0.5
const MIN_VERTICAL_MOVE = -0.5
const MAX_HORIZONTAL_MOVE = 0.5

var camera_zoom_position = Vector3.ZERO
var camera_pan_position = Vector3.ZERO

var camera_pan_horizontal_percentage = 0.5
var camera_pan_vertical_percentage = 0.5
var camera_zoom_percentage = 1.0

var rotating = false
var moving = false
var animating_camera = false
var in_control_panel = false
var prev_mouse_position
var next_mouse_position

# Duration in seconds
func move_camera(target_position: Vector3, duration: float):
	animating_camera = true
	
	# Reset extra camera values
	camera_pan_horizontal_percentage = 0.5
	camera_pan_vertical_percentage = 0.5
	camera_zoom_percentage = 1.0
	
	camera_pan_position = Vector3.ZERO
	camera_zoom_position = Vector3.ZERO
	
	var start_time = Time.get_ticks_msec()
	var start_position = camera.position
	
	duration *= 1000.0
	
	while (Time.get_ticks_msec() - start_time <= duration):
		var step = (Time.get_ticks_msec() - start_time) / duration
		camera.position = lerp(start_position, target_position, step)
		await get_tree().process_frame
		
	camera.position = target_position
	animating_camera = false
	

# Duration in seconds
func rotate_character(target_vector: Vector3, duration: float):
	var start_time = Time.get_ticks_msec()
	var start_rotation = node_to_rotate.rotation_degrees
	
	duration *= 1000.0
	
	while (Time.get_ticks_msec() - start_time <= duration):
		var step = (Time.get_ticks_msec() - start_time) / duration
		node_to_rotate.rotation_degrees = lerp(start_rotation, target_vector, step)
		await get_tree().process_frame
		
	node_to_rotate.rotation_degrees = target_vector
	

func _process(delta):
	if Input.is_action_just_pressed("exit"):
		close()
		SceneManager.goto_scene_no_load("res://scenes/main_menu.tscn")
		
	
	if Input.is_action_just_pressed("Rotate"):
		# Only control characer and camera in central panel
		if in_control_panel:
			rotating = true
			prev_mouse_position = get_viewport().get_mouse_position()
	
	if Input.is_action_just_released("Rotate"):
		rotating = false

	if Input.is_action_just_pressed("Move"):
		# Only control characer and camera in central panel
		if in_control_panel:
			moving = true
			prev_mouse_position = get_viewport().get_mouse_position()
	
	if Input.is_action_just_released("Move"):
		moving = false
	
	if rotating:
		reset_camera_button.show()
		next_mouse_position = get_viewport().get_mouse_position()
		node_to_rotate.rotate_y((next_mouse_position.x - prev_mouse_position.x) * .4 * delta)
		prev_mouse_position = next_mouse_position
	
	if moving:
		reset_camera_button.show()
		next_mouse_position = get_viewport().get_mouse_position()
		
		var mouse_delta = next_mouse_position - prev_mouse_position
		
		# Horizontal panning
		camera_pan_horizontal_percentage -= mouse_delta.x * .2 * delta
		camera_pan_horizontal_percentage = clampf(camera_pan_horizontal_percentage, 0.0, 1.0)
		
		# Vertical panning
		camera_pan_vertical_percentage += mouse_delta.y * .3 * delta
		camera_pan_vertical_percentage = clampf(camera_pan_vertical_percentage, 0.0, 1.0)
		
		camera_pan_position.x = lerp(-MAX_HORIZONTAL_MOVE, MAX_HORIZONTAL_MOVE, camera_pan_horizontal_percentage)
		camera_pan_position.y = lerp(MIN_VERTICAL_MOVE, MAX_VERTICAL_MOVE, camera_pan_vertical_percentage)
		
		prev_mouse_position = next_mouse_position
	
	# Zoom in
	if Input.is_action_just_pressed("ScrollUp"):
		if in_control_panel:
			reset_camera_button.show()
			camera_zoom_percentage -= SCROLL_SPEED
			camera_zoom_percentage = max(camera_zoom_percentage, 0.0)
		
	
	# Zoom out
	if Input.is_action_just_pressed("ScrollDown"):
		if in_control_panel:
			reset_camera_button.show()
			camera_zoom_percentage += SCROLL_SPEED
			camera_zoom_percentage = min(camera_zoom_percentage, 1.0)
		
	
	# Get zoom position that is added to default position
	camera_zoom_position = lerp(Vector3(0,0,MIN_SCROLL), Vector3(0,0,MAX_SCROLL), camera_zoom_percentage)
	
	# Get final camera position
	if not animating_camera:
		camera.position = default_camera_position + (camera.basis * (camera_zoom_position + camera_pan_position))
	

# Button press functions
func _on_reset_button_pressed():
	load_default_character()
	

func _on_reset_camera_pressed():
	move_camera(default_camera_position, 0.2)
	rotate_character(default_node_rotation, 0.2)
	reset_camera_button.hide()
	

func _on_cancel_button_pressed():
	close()
	SceneManager.goto_scene_no_load("res://scenes/main_menu.tscn")
	

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
	

func _on_hair_button_pressed():
	cycle_part_variation("hair")
	

func _on_top_button_pressed():
	cycle_part_variation("top")
	

func _on_pants_button_pressed():
	cycle_part_variation("bottom")
	

func _on_central_panel_mouse_entered():
	in_control_panel = true
	

func _on_central_panel_mouse_exited():
	in_control_panel = false
	

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
	

func _on_head_left_arrow_pressed():
	cycle_part_variation("head", -1)
	

func _on_head_button_pressed():
	cycle_part_variation("head")
	

func _on_top_left_arrow_pressed():
	cycle_part_variation("top", -1)
	

func _on_mask_left_arrow_pressed():
	cycle_part_variation("mask", -1)
	

func _on_mask_button_pressed():
	cycle_part_variation("mask")
	

func _on_mask_right_arrow_pressed():
	cycle_part_variation("mask")
	

func _on_pants_left_arrow_pressed():
	cycle_part_variation("bottom", -1)
	

func _on_pants_right_arrow_pressed():
	cycle_part_variation("bottom")
	

func _on_facial_left_arrow_pressed():
	save_changes()
	cycle_part_variation("facial", -1)
	MODEL_PARTS.facial.button.grab_focus()
	

func _on_bangs_left_arrow_pressed():
	save_changes()
	cycle_part_variation("bangs", -1)
	MODEL_PARTS.bangs.button.grab_focus()
	audio_player.play(press_back_sound)
	

func _on_shoes_left_arrow_pressed():
	cycle_part_variation("shoes", -1)
	

func _on_shoes_button_pressed():
	cycle_part_variation("shoes")
	

func _on_shoes_right_arrow_pressed():
	cycle_part_variation("shoes")
	

func select_sex(sex: String):
	if sex == "male":
		current_sex_selection = "male"
		sex_button.text = "MALE"
	elif sex == "female":
		current_sex_selection = "female"
		sex_button.text = "FEMALE"
	
	if sex_button.has_focus():
		sex_button.text = "< %s >" % sex_button.text
	

func toggle_sex_selection():
	if current_sex_selection == "male":
		select_sex("female")
	else:
		select_sex("male")
	

func _on_str_spin_box_value_changed(value):
	try_set_attribute_value("strength", value)
	

func _on_agi_spin_box_value_changed(value):
	try_set_attribute_value("agility", value)
	

func _on_dex_spin_box_value_changed(value):
	try_set_attribute_value("dexterity", value)
	

func _on_wis_spin_box_value_changed(value):
	try_set_attribute_value("wisdom", value)
	

func _on_attr_reset_button_pressed():
	reset_attributes()
	

func _on_attr_randomize_button_pressed():
	reset_attributes()
	
	while current_available_points > 0:
		var attr_names = []
		
		for attr in ATTRIBUTES:
			attr_names.append(attr)
		
		while attr_names.size() > 0:
			var index = rng.randi_range(0, attr_names.size() - 1)
			var add_value = rng.randi_range(0, current_available_points)
			var curr_val = current_attribute_allocation[attr_names[index]]
			
			try_set_attribute_value(attr_names[index], curr_val + add_value)
			attr_names.remove_at(index)
	

func save_preset():
	var char_dict = {
		"name": char_name.text,
		"sex": current_sex_selection,
		"appearance" : character.save_appearance(),
		"stats": {
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
		},
	}
	SceneManager.goto_scene("res://scenes/main.tscn")
	PlayerEntity.load_player_data(char_dict)
	close()
	

func get_current_data():
	var data = {
		"sex": current_sex_selection,
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
	current_sex_selection = data["sex"]
	select_sex(current_sex_selection)
	
	character.load_appearance(data.appearance)
	
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
	

func load_preset():
	var save_game = FileAccess.open("user://".path_join(preset_filename), FileAccess.READ)
	while save_game.get_position() < save_game.get_length():
		var json_string = save_game.get_line()
	
		# Creates the helper class to interact with JSON
		var json = JSON.new()
	
		# Check if there is any error while parsing the JSON string, skip in case of failure
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue
	
		# Get the data from the JSON object
		var data = json.get_data()
		char_name.text = data["name"]
		current_sex_selection = data["sex"]
		character.load_appearance(data["appearance"])
		current_attribute_allocation = data["attributes"]
	

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
	select_sex(current_sex_selection)
	audio_player.play(focus_sound)
	

func _on_sex_button_focus_exited():
	update_lock_texture(sex_lock, lock_selection["sex"], sex_button.has_focus())
	select_sex(current_sex_selection)
	

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
	save_preset()
	

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
	
