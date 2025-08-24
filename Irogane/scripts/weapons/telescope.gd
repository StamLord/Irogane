extends Node3D

@onready var telecam = $telecam
@export var min_fov = 70.0
@export var max_fov = 1.0
@export var min_sensitivity = 0.04
@export var steps = 10

var current_step = 0

signal telescope_on(state)

func _ready():
	telecam.fov = min_fov
	visibility_changed.connect(visibility_change)
	

func _process(delta):
	if not visible:
		return
	
	set_telecam_active(Input.is_action_pressed("attack_secondary"))
	
	if telecam.current:
		if Input.is_action_just_pressed("scroll_up"):
			zoom_to(current_step + 1)
		elif Input.is_action_just_pressed("scroll_down"):
			zoom_to(current_step - 1)
	

func zoom_to(step):
	step = clamp(step, 0, steps - 1)
	current_step = step
	var t = step / float(steps)
	telecam.fov = lerp(min_fov, max_fov, t)
	
	ControlSettings.mouse_sesitivity_multiplier_variable = lerp(1.0, min_sensitivity, t)
	

func set_telecam_active(state):
	telecam.current = state
	CameraEntity.main_camera.current = !state
	telescope_on.emit(state)
	
	if not state: # Reset when closed
		zoom_to(0)
	

func visibility_change():
	if not visible:
		set_telecam_active(false)
	
