extends TextureProgressBar

@onready var pin_prefab = %pin_prefab
@onready var rotation_label = %rotation_label
@onready var mouse_rotation_label = %mouse_rotation_label
@onready var target = %target
@onready var audio = %audio
@onready var audio_2 = %audio2
@onready var audio_loop = %audio_loop
@onready var circle_draw = $"../circle_draw"

const PIN_HIT_CLIP = preload("res://assets/audio/lock_pick_minigame/pin_hit.wav")
const PIN_UNLOCKED_CLIP = preload("res://assets/audio/lock_pick_minigame/pin_unlocked.wav")
const ROTATING_CYLINDER_CLIP = preload("res://assets/audio/lock_pick_minigame/rotating_cylinder.wav")
const RESET_PINS_CLIP = preload("res://assets/audio/lock_pick_minigame/reset_pins.wav")

var pin_locations = [
	Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1),
	Vector2(1, 1).normalized(), Vector2(-1, -1).normalized(),
	Vector2(-1, 1).normalized(), Vector2(1, -1).normalized()]

var pin_radius = 100.0
var open_pin_radius = 140
var failed_pin_radius = 200

var enabled = false
var prev_mouse_angle = null
var rotation_speed = 250
var pin_buttons = ['W', 'A', 'S', 'D']
var pin_push_multipliers = [1, 1.5, 2]

var active_pins = [] 	# Array of dicts:
						#{  pin: Control,
						#   button: String,
						#   direction: Vector2,
						#   height: float,
						#   velocity: Vector2}

var unused_pin_locations = []

var current_pin = null

func _ready():
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	prev_mouse_angle = rad_to_deg(get_global_mouse_position().angle())
	
	initialize_pins(3)
	circle_draw.add_circle(failed_pin_radius, 16, 4.0)
	

func _process(_delta):
	var mouse_angle = get_mouse_angle()
	
	# Debug purposes
	mouse_rotation_label.global_position = get_global_mouse_position() + Vector2(10, -10)
	mouse_rotation_label.text = String("%.2f" % mouse_angle)
	if Input.is_action_just_pressed("defend"):
		initialize_pins(3)
	
	# Rotation
	var angle_delta = mouse_angle - prev_mouse_angle
	prev_mouse_angle = mouse_angle
	
	if angle_delta > 0:
		rotation_degrees += rotation_speed * _delta
		rotation_degrees = fmod(rotation_degrees, 360.0)
		play_sound_loop(ROTATING_CYLINDER_CLIP)
	elif angle_delta < 0:
		rotation_degrees -= rotation_speed * _delta
		if rotation_degrees < 0:
			rotation_degrees += 360.0
		rotation_degrees = fmod(rotation_degrees, 360.0)
		play_sound_loop(ROTATING_CYLINDER_CLIP)
	else:
		stop_sound_loop()
	
	# Debug purposes
	rotation_label.text = String("%.2f" % rotation_degrees)
	
	# Input
	var w = Input.is_action_just_pressed("forward")
	var a = Input.is_action_just_pressed("left")
	var s = Input.is_action_just_pressed("backward")
	var d = Input.is_action_just_pressed("right")
	
	current_pin = get_current_pin()
	if current_pin != null:
		var btn = current_pin["button"] 
		if btn == "W" and w or btn == "A" and a or btn == "S" and s or btn == "D" and d:
			#current_pin["velocity"] = current_pin["base_position"] * 100.0 * _delta
			current_pin["height"] += 20 * current_pin["push_mult"]
			if is_pin_open(current_pin):
				play_sound(PIN_UNLOCKED_CLIP)
			else:
				play_sound(PIN_HIT_CLIP)
	
	update_pins(_delta)
	
	if is_unlocked():
		target.tint_progress.a = 1.0
		
	else:
		target.tint_progress.a = 0.5
	

func get_mouse_angle():
	var screen_size = get_viewport().get_visible_rect().size
	var mouse_pos = get_global_mouse_position() - screen_size * 0.5 # Center of screen as origin
	mouse_pos = mouse_pos.normalized() * 100
	return rad_to_deg(mouse_pos.angle())
	

func spawn_pin():
	if pin_prefab == null:
		return
	
	var pin = pin_prefab.duplicate()
	pin_prefab.get_parent().add_child(pin)
	pin.visible = true
	
	var pin_position = unused_pin_locations.pick_random()
	unused_pin_locations.erase(pin_position)
	pin.position = finalized_pin_position(pin, pin_position, pin_radius)
	
	var pin_button = pin_buttons.pick_random()
	var label = pin.get_node("label")
	if label != null:
		label.text = pin_button
	
	active_pins.append(
		{	"pin": pin,
			"button": pin_button,
			"direction": pin_position,
			"push_mult": pin_push_multipliers.pick_random(),
			"height": pin_radius,
			"velocity": Vector2.ZERO})
	

func initialize_pins(amount: int):
	for pin in active_pins:
		pin["pin"].queue_free()
	
	active_pins.clear()
	unused_pin_locations = pin_locations.duplicate()
	for i in range(amount):
		spawn_pin()
	
	target.rotation_degrees = randi_range(1, 8) * 360 / 8 + 22.5
	

func get_current_pin():
	var closest_pin = null
	var closest_angle_delta = INF
	
	# Find closest pin by smallest angle
	for pin in active_pins:
		var pin_object = pin["pin"]
		var pos = pin_object.position + Vector2(pin_object.size.x / 2, pin_object.size.y / 2) # De-offset
		var angle = rad_to_deg(pos.angle())
		angle = fmod(angle + 360, 360.0) # Convert to 0...360
		
		var rot = rotation_degrees
		
		# Prevent edge case of comparing 355 and 5 angles
		if abs(rot - angle) > 180:
			if rot < angle:
				rot += 360
			else:
				angle += 360
		
		# Check orientation
		if angle < rot + 15 and angle > rot - 15: 
			if abs(rot - angle) < closest_angle_delta:
				closest_pin = pin
				closest_angle_delta = abs(rot - angle)
	
	return closest_pin
	

func update_pins(delta):
	var i = 0
	for pin in active_pins:
		## Spring behavior
		#var pin_origin = finalized_pin_position(pin["pin"], pin["base_position"])
		#var to_pin_origin = pin_origin - pin["pin"].position
		#var distance = to_pin_origin.length()
		#var force = 0.1 * max(0, distance - 1)	# Hooke's law + clamping to prevent rope pushing back when too close
		#
		#pin["velocity"] += to_pin_origin.normalized() * force * delta 
		#pin["velocity"] *= (1.0 - 0.99 * delta)									# Dampen
		#pin["pin"].position += pin["velocity"]
		
		## New behavior
		var target_height = pin_radius
		if is_pin_open(pin) and current_pin != pin:
			target_height = open_pin_radius
		
		var height = pin["height"]
		var height_delta = target_height - height
		var force = clamp(height_delta, -1, 1) * 80 * delta
		pin["height"] += force 
		pin["pin"].position = finalized_pin_position(pin["pin"], pin["direction"], height)
		
		if pin["height"] > failed_pin_radius - pin["pin"].size.x / 2:
			failed_attempt()
		
		i += 1
	

func is_pin_open(pin: Dictionary):
	var size = pin["pin"].size.x
	var height = pin["height"]
	return height > pin_radius + size / 2
	

func finalized_pin_position(pin: Control, base_position: Vector2, radius: float):
	var final = base_position * radius
	final -= Vector2(pin.size.x / 2, pin.size.y / 2) # Offset
	return final
	

func all_pins_open():
	for pin in active_pins:
		if not is_pin_open(pin):
			return false
	return true
	

func is_unlocked():
	if not all_pins_open():
		return false
	
	var rot = rotation_degrees
	var target_rot = target.rotation_degrees
	
	# Prevent edge case of comparing 355 and 5 angles
	if abs(rot - target_rot) > 180:
		if rot < target_rot:
			rot += 360
		else:
			target_rot += 360
	
	# Check orientation
	return target_rot < rot + 15 and target_rot > rot - 15 
	

func failed_attempt():
	process_mode = Node.PROCESS_MODE_DISABLED
	await get_tree().create_timer(1.0).timeout
	process_mode = Node.PROCESS_MODE_INHERIT
	reset_pins()
	

func reset_pins():
	for pin in active_pins:
		pin["height"] = pin_radius
	
	play_fail_sound()
	

func play_sound(clip):
	audio.stream = clip
	audio.play()
	

func play_sound_loop(clip):
	if audio_loop.playing:
		return
	
	audio_loop.stream = clip
	audio_loop.play()
	

func stop_sound_loop():
	audio_loop.stop()
	

func play_fail_sound():
	audio_2.stream = RESET_PINS_CLIP
	audio_2.play()
	
