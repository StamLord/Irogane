extends Interactive

@export var state : bool
@export var on_position : Vector3
@export var on_rotation : Vector3
@export var animation_time : float

var origin_position : Vector3
var origin_rotation : Vector3

var is_animating_position : bool
var is_animating_rotation : bool

func _ready():
	origin_position = get_parent().position
	origin_rotation = get_parent().rotation_degrees

func use(interactor):
	state = !state
	
	if state:
		animate_position(origin_position, origin_position + on_position)
		animate_rotation(origin_rotation, origin_rotation + on_rotation)
	else:
		animate_position(origin_position + on_position, origin_position)
		animate_rotation(origin_rotation + on_rotation, origin_rotation)
	

func animate_position(from, to):
	is_animating_position = true
	var start_time = Time.get_ticks_msec()
	while Time.get_ticks_msec() - start_time <= animation_time * 1000:
		var t = (Time.get_ticks_msec() - start_time) / (animation_time * 1000)
		get_parent().position = lerp(from, to, t)
		await get_tree().create_timer(0).timeout
	
	get_parent().position = to
	is_animating_position = false
	
func animate_rotation(from, to):
	is_animating_rotation = true
	var start_time = Time.get_ticks_msec()
	while Time.get_ticks_msec() - start_time <= animation_time * 1000:
		var t = (Time.get_ticks_msec() - start_time) / (animation_time * 1000)
		get_parent().rotation_degrees = lerp(from, to, t)
		await get_tree().create_timer(0).timeout
	
	get_parent().rotation_degrees = to
	is_animating_rotation = false
