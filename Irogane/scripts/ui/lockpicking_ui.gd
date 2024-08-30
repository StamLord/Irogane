extends TextureProgressBar


var enabled = false
var prev_angle = null
var rotation_speed = 250

func _ready():
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)
	prev_angle = get_local_mouse_position().angle()
	

func _process(_delta):
	#if Input.is_action_just_pressed("alpha0"):
		#enabled = not enabled
		#visible = enabled
		#if enabled:
			#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		#else:
			#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	#
	#if not enabled:
		#return

	var angle = get_local_mouse_position().angle()
	var angle_delta = angle - prev_angle
	prev_angle = angle
	print("angle ",angle)
	print("radial_initial_angle ",radial_initial_angle)
	if angle_delta > 0:
		radial_initial_angle += rotation_speed * _delta
	elif angle_delta < 0:
		radial_initial_angle -= rotation_speed * _delta
	
