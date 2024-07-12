extends Node3D

@onready var jump_area = $jump_area
@onready var land_area = $land_area
@onready var fail_area = $fail_area
@onready var label_3d = $Label3D

var total_jumps = 0
var successful_jumps = 0

var jump_started = false
var jumping_body = null

func _ready():
	jump_area.body_entered.connect(body_entered_jump_area)
	

func body_entered_jump_area(body):
	if body is PlayerStateMachine:
		body.on_state_enter.connect(state_enter)
		jumping_body = body
	

func state_enter(state_name):
	if not jump_started and state_name == "jump":
		if jumping_body != null and jump_area.overlaps_body(jumping_body):
			jump_started = true
			return
	
	if not jump_started:
		return
	
	if state_name not in ["walk", "run", "crouch", "vault"]:
		return
	
	jump_started = false
	var in_fail_area = jumping_body != null and fail_area.overlaps_body(jumping_body)
	var in_success_area = jumping_body != null and land_area.overlaps_body(jumping_body)
	
	if in_success_area or state_name == "vault":
		total_jumps += 1
		successful_jumps += 1
		update_label()
		jumping_body = null
	elif in_fail_area:
		total_jumps += 1
		update_label()
		jumping_body = null
	

func update_label():
	if label_3d == null:
		return
	
	var percentage = successful_jumps / float(total_jumps)
	label_3d.text = str(successful_jumps) + "/" + str(total_jumps)
	
	var color = min(floor(max(percentage - 0.5, 0.0) * 6), 2)
	
	label_3d.modulate = [Color.RED, Color.YELLOW, Color.GREEN][color]
	
