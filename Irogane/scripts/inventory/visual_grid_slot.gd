extends TextureRect

@onready var free = $free
@onready var occupied = $occupied

var is_occupied = false
var from_scale_free = Vector2.ONE * 1.25
var to_scale_free = Vector2.ONE
var from_scale_occupied = Vector2.ONE * .5
var to_scale_occupied = Vector2.ONE
var scale_time_ms = 100.0

var from_to_rotation_free = Vector2(-45, 0)
var from_to_rotation_occupied = Vector2(-45, 0)
var rotation_time_ms = 100.0

var start_animate = 0

func _process(_delta):
	if free == null or occupied == null:
		return
		
	# Get scale
	var t = (Time.get_ticks_msec() - start_animate) / scale_time_ms
	var scale = Vector2()
	if t < 1.0:
		if is_occupied:
			scale = lerp(from_scale_occupied, to_scale_occupied, t)
		else:
			scale = lerp(from_scale_free, to_scale_free, t)
	else:
		if is_occupied:
			scale = to_scale_occupied
		else:
			scale = to_scale_free
	
	# Get rotation
	t = (Time.get_ticks_msec() - start_animate) / rotation_time_ms
	var angle = from_to_rotation_occupied.x
	if t < 1.0:
		if is_occupied:
			angle = lerp(from_to_rotation_occupied.x, from_to_rotation_occupied.y, t)
		else:
			angle = lerp(from_to_rotation_free.x, from_to_rotation_free.y, t)
	else:
		if is_occupied:
			angle = from_to_rotation_occupied.y
		else:
			angle = from_to_rotation_free.y
	
	# Set scale & rotation
	if is_occupied:
		occupied.scale = scale
		occupied.rotation = deg_to_rad(angle)
	else:
		free.scale = scale
		free.rotation = deg_to_rad(angle)

func occupy(state):
	is_occupied = state
	
	if free == null or occupied == null:
		return
	
	start_animate = Time.get_ticks_msec()
	
	if is_occupied:
		free.visible = false
		occupied.visible = true
	else:
		occupied.visible = false
		free.visible = true
