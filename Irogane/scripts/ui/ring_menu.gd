extends Control
class_name RingMenu

@export var open_button : String
@export var items : Array
@export var open_duration = 0.1
@export var open_scale_curve : CurveTexture
@export var open_rotation_curve : CurveTexture

# Alpha values of item textures
@export var item_selected_alpha = 0.5
@export var item_alpha = 0.0

@onready var section_parent = $background
@onready var section_texture = $background/section_prefab
@onready var section_label = $background/section_label

var last_mouse_mode : Input.MouseMode
var start_mouse_pos = Vector2.ZERO
var current_selection = 0
var section_size = 0
var sections = []
var labels = []

signal item_selected(selection_name)

func _ready():
	last_mouse_mode = Input.mouse_mode
	initialize()
	

func parse_label(text: String):
	var text_array = text.split("_")
	for i in text_array.size():
		text_array[i] = text_array[i].capitalize()
	return " ".join(text_array)
	

func initialize():
	# Ensure closed at start
	if visible:
		close()
	
	# Get section sizes
	section_size = 360.0 / items.size()
	
	# Clear old textures & labels ( Needed if we call initialize during game because items have changed )
	clear_array(sections)
	clear_array(labels)
		
	# Create section textures & labels
	section_texture.value = (section_size / 360.0) * (section_texture.max_value - section_texture.min_value)
	section_texture.modulate.a = item_alpha
	for i in range(items.size()):
		# Texture
		var new_texture = section_texture.duplicate()
		new_texture.visible = true
		section_parent.add_child(new_texture)
		new_texture.position = Vector2.ZERO
		new_texture.rotation_degrees = i * section_size
		sections.append(new_texture)
		
		# Label
		var new_label = section_label.duplicate()
		new_label.visible = true
		new_label.text = parse_label(items[i])
		section_parent.add_child(new_label)
		var parent_center = section_parent.size * 0.5 
		var label_center = new_label.size * 0.5 
		var rotated_position = Vector2(0, -150).rotated(deg_to_rad((i + 0.5) * section_size))
		new_label.position = parent_center + rotated_position - label_center
		labels.append(new_label)
	

func initialize_items(selection_items: Array):
	items = selection_items
	initialize()
	

func _process(delta):
	if open_button:
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
		sections[current_selection].modulate.a = item_selected_alpha
		
		# Dehighlight last selection
		if last_selection != current_selection:
			sections[last_selection].modulate.a = item_alpha
	

func open():
	visible = true
	start_mouse_pos = get_global_mouse_position()
	last_mouse_mode = Input.mouse_mode
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	open_animation()
	

func close():
	visible = false
	item_selected.emit(items[current_selection])
	Input.mouse_mode = last_mouse_mode
	

func open_animation():
	var start_time = Time.get_ticks_msec()
	var duration = open_duration * 1000 # msec
	
	while Time.get_ticks_msec() - start_time <= duration:
		var t = (Time.get_ticks_msec() - start_time) / duration
		
		# Scale
		if open_scale_curve:
			section_parent.scale = Vector2.ONE * open_scale_curve.curve.sample(t)
		else:
			section_parent.scale = lerp(Vector2.ZERO, Vector2.ONE, t)
		
		# Rotation
		if open_rotation_curve:
			section_parent.rotation = open_rotation_curve.curve.sample(t)
		
		await get_tree().process_frame
	
	if open_scale_curve:
		section_parent.scale = Vector2.ONE * open_scale_curve.curve.sample(1.0)
	else:
		section_parent.scale = lerp(Vector2.ZERO, Vector2.ONE, 1.0)
	
	if open_rotation_curve:
		section_parent.rotation = open_rotation_curve.curve.sample(1.0)
	

func clear_array(array : Array):
	for member in array:
		member.queue_free()
	array.clear()
	
