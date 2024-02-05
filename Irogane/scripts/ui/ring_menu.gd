extends Control
class_name RingMenu

@export var open_button : String
@export var items : Array[String]
@export var open_duration = 0.1
@export var open_scale_curve : CurveTexture

@onready var section_parent = $background
@onready var section_texture = $background/section_prefab

var last_mouse_mode : Input.MouseMode
var start_mouse_pos = Vector2.ZERO
var current_selection = 0
var section_size = 0
var sections = []

signal item_selected(selection_name)

func _ready():
	# Ensure not visible at start
	visible = false
	
	# Get section sizes
	section_size = 360.0 / items.size()
	
	# Create section textures
	section_texture.value = (section_size / 360.0) * (section_texture.max_value - section_texture.min_value)
	for i in range(items.size()):
		var new_section = section_texture.duplicate()
		new_section.visible = true
		section_parent.add_child(new_section)
		new_section.position = Vector2.ZERO
		new_section.rotation_degrees = i * section_size
		sections.append(new_section)
	

func _process(delta):
	if Input.is_action_just_pressed(open_button) and not visible:
		open()
	elif not Input.is_action_pressed(open_button) and visible:
		close()
	
	if visible:
		# Calculate current selection
		var mouse_pos = get_global_mouse_position()
		var dir = (mouse_pos - start_mouse_pos).normalized()
		var angle = rad_to_deg(Vector2(0,-1).angle_to(dir))
		var positive_angle = fmod(angle + 360.0, 360.0) # Use modulo to wrap negative angles to the equivalent positive angle
		var last_selection = current_selection
		current_selection = floori(positive_angle / section_size)
		
		# Highlight current selection
		sections[current_selection].modulate.a = 1
		
		# Dehighlight last selection
		if last_selection != current_selection:
			sections[last_selection].modulate.a = 0.5
		
	

func open():
	visible = true
	start_mouse_pos = get_global_mouse_position()
	last_mouse_mode = Input.mouse_mode
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	open_animation()
	

func close():
	visible = false
	item_selected.emit(current_selection)
	Input.mouse_mode = last_mouse_mode
	

func open_animation():
	var start_time = Time.get_ticks_msec()
	var duration = open_duration * 1000 # msec
	
	while Time.get_ticks_msec() - start_time <= duration:
		var t = (Time.get_ticks_msec() - start_time) / duration
		
		if open_scale_curve:
			section_parent.scale = Vector2.ONE * open_scale_curve.curve.sample(t)
		else:
			section_parent.scale = lerp(Vector2.ZERO, Vector2.ONE, t)
		
		await get_tree().process_frame
	
	if open_scale_curve:
		section_parent.scale = Vector2.ONE * open_scale_curve.curve.sample(1.0)
	else:
		section_parent.scale = lerp(Vector2.ZERO, Vector2.ONE, 1.0)
	
