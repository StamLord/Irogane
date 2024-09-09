extends TextureRect

@onready var pin_prefab = %pin_prefab
@onready var planetary_gear_parent = $"../planetary_gear_parent"
@onready var inner_gear = $"../planetary_gear_parent/inner_gear"
@onready var inner_gear_2 = $"../planetary_gear_parent/inner_gear2"
@onready var inner_gear_3 = $"../planetary_gear_parent/inner_gear3"

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

var pin_radius = 120.0
var open_pin_radius = 190
var failed_pin_radius = 300
var pin_fall_speed = 200
var pin_push_force = 40

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

var debug = false

signal failed()
signal success()

func _ready():
	# If running scene from editor
	if owner.owner == null:
		start_minigame()
	

func start_minigame():
	InputContextManager.switch_context(InputContextType.MINIGAME)
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	prev_mouse_angle = rad_to_deg(get_global_mouse_position().angle())
	
	initialize_pins(3)
	
	# Draw failed circle
	circle_draw.add_circle(failed_pin_radius - pin_prefab.size.x * 0.5, 64, 4.0, Color.DARK_RED, Color.WHITE)
	
	owner.visible = true
	

func end_minigame():
	InputContextManager.switch_context(InputContextType.GAME)
	stop_sound_loop()
	owner.visible = false
	

func _process(_delta):
	if not is_visible_in_tree():
		return
	
	var mouse_angle = get_mouse_angle()
	
	if debug:
		mouse_rotation_label.global_position = get_global_mouse_position() + Vector2(10, -10)
		mouse_rotation_label.text = String("%.2f" % mouse_angle)
		if Input.is_action_just_pressed("defend"):
			initialize_pins(3)
	
	# Rotation
	var angle_delta = mouse_angle - prev_mouse_angle
	prev_mouse_angle = mouse_angle
	
	if angle_delta > 0:
		rotate_object(get_node("."), rotation_speed * _delta)
		rotate_object(inner_gear, rotation_speed * _delta * 3)
		rotate_object(inner_gear_2, rotation_speed * _delta * 3)
		rotate_object(inner_gear_3, rotation_speed * _delta * 3)
		play_sound_loop(ROTATING_CYLINDER_CLIP)
	elif angle_delta < 0:
		rotate_object(get_node("."), -rotation_speed * _delta)
		rotate_object(inner_gear, -rotation_speed * _delta * 3)
		rotate_object(inner_gear_2, -rotation_speed * _delta * 3)
		rotate_object(inner_gear_3, -rotation_speed * _delta * 3)
		play_sound_loop(ROTATING_CYLINDER_CLIP)
	else:
		stop_sound_loop()
	
	if debug:
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
			current_pin["height"] += pin_push_force * current_pin["push_mult"]
			if is_pin_open(current_pin):
				play_sound(PIN_UNLOCKED_CLIP)
			else:
				play_sound(PIN_HIT_CLIP)
	
	update_pins(_delta)
	
	if is_unlocked():
		target.tint_progress.a = 1.0
		success.emit()
	else:
		target.tint_progress.a = 0.5
	

func get_mouse_angle():
	var screen_size = get_viewport().get_visible_rect().size
	var mouse_pos = get_global_mouse_position() - screen_size * 0.5 # Center of screen as origin
	mouse_pos = mouse_pos.normalized() * 100
	return rad_to_deg(mouse_pos.angle())
	

func rotate_object(object: TextureRect, amount: float):
	object.rotation_degrees += amount
	if object.rotation_degrees < 0:
		object.rotation_degrees += 360.0
	object.rotation_degrees = fmod(object.rotation_degrees, 360.0)
	

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
	
	var spring_rot = pin.get_node("spring_rotation")
	if spring_rot != null:
		var angle = rad_to_deg(pin_position.angle())
		spring_rot.rotation_degrees = angle + 90
	
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
		
		# Remove jittering
		if abs(height_delta) < 2:
			height_delta = 0
		
		# Speed should be consistent regardless of delta
		height_delta = clamp(height_delta, -1, 1)
		
		var force = height_delta * pin_fall_speed * delta
		pin["height"] += force 
		pin["pin"].position = finalized_pin_position(pin["pin"], pin["direction"], height)
		
		if pin["height"] > failed_pin_radius - pin["pin"].size.x / 2:
			failed_attempt()
		
		var spring = pin["pin"].get_node("spring_rotation/spring")
		if spring != null:
			var spring_length = spring.size.y
			var distance = failed_pin_radius + pin["pin"].size.x - height - pin_radius
			distance = max(0, distance) # No spring when negative distance
			spring.scale.y = distance / spring_length
		
		i += 1
	

func is_pin_open(pin: Dictionary):
	var size_x = pin["pin"].size.x
	var height = pin["height"]
	return height > pin_radius + size_x / 2
	

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
	failed.emit()
	CameraShaker.shake(0.25, 0.2)
	play_fail_sound()
	
	process_mode = Node.PROCESS_MODE_DISABLED
	await get_tree().create_timer(1.0).timeout
	process_mode = Node.PROCESS_MODE_INHERIT
	
	reset_pins()
	

func reset_pins():
	for pin in active_pins:
		pin["height"] = pin_radius
	

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
	
