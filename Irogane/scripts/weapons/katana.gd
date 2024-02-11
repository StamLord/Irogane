extends Node3D

@export var light_attack_info = AttackInfo.new(5, 10, Vector3.FORWARD * 2)
@export var heavy_attack_info = AttackInfo.new(5, 10, Vector3.FORWARD * 2)
@export var uppward_attack_info = AttackInfo.new(5, 10, Vector3.UP * 6)

@export var combo_list = [
	{
		"state" : "light_1",
		"combo" : "l",
		"movement" : Vector3(0, 0, -2),
		"movement_duration" : 0.1,
	},
	{
		"state" : "light_2",
		"combo" : "ll",
		"movement" : Vector3(0, 0, -2),
		"movement_duration" : 0.1,
	},
	{
		"state" : "light_3",
		"combo" : "lll",
		"movement" : Vector3(0, 0, -2),
		"movement_duration" : 0.1,
	},
	{
		"state" : "light_3",
		"combo" : "lllr",
		"movement" : Vector3(0, 0, -6),
		"movement_duration" : 0.1,
	},
	{
		"state" : "heavy_1",
		"combo" : "r",
	},
	{
		"state" : "heavy_2",
		"combo" : "rr",
	},
	{
		"state" : "heavy_3",
		"combo" : "rrr",
	},
	{
		"state" : "uppward",
		"combo" : "j+r",
	},
]

@export var combo_cancel_time = 1
@export var display_moves = true
@export var max_display_moves = 10
@export var jump_input_window = 0.25

@onready var anim_tree : AnimationTree = $katana_pov_hands/AnimationTree
@onready var anim_state_machine : AnimationNodeStateMachinePlayback = anim_tree["parameters/playback"]
@onready var moves_container = $moves_display/moves_container

@onready var hitbox = $katana_pov_hands/first_person_rig/Skeleton3D/hand_r_attachment/hitbox
@onready var upward_hitbox = $katana_pov_hands/upward_hitbox

var combo = []
var last_combo_addition = 0
var last_primary = -1
var last_secondary = -1
var last_jump = -1

func _ready():
	hitbox.on_collision.connect(hit)
	upward_hitbox.on_collision.connect(hit)
	

func _process(delta):
	if not visible:
		return
	
	if UIManager.window_count() > 0:
		return
	
	var state = anim_state_machine.get_current_node()
	if state == "idle":
		hitbox.set_active(false)
	
	if Input.is_action_just_pressed("jump"):
		last_jump = Time.get_ticks_msec()
	
	if Input.is_action_just_pressed("defend"):
		anim_state_machine.start("defend_start")
	elif Input.is_action_just_pressed("attack_primary"):
		add_to_combo("l")
		hitbox.clear_collisions()
		hitbox.set_active(true)
	elif Input.is_action_just_pressed("attack_secondary"):
		if is_jumping():
			add_to_combo("j+r")
		else:
			add_to_combo("r")
		
		hitbox.clear_collisions()
		hitbox.set_active(true)
	
	if not combo.is_empty() and Time.get_ticks_msec() - last_combo_addition > combo_cancel_time * 1000:
		reset_combo()
	

func add_to_combo(move):
	combo.append(move)
	last_combo_addition = Time.get_ticks_msec()
	
	var matching_combo = validate_combo(combo)
	
	# If no combo exists with the new move added,
	# start a new combo with only this move
	if matching_combo == null:
		reset_combo()
		combo.append(move)
		matching_combo = validate_combo(combo)
	
	# Play animation state if a combo was found
	if matching_combo != null:
		anim_state_machine.start(matching_combo.state)
		if matching_combo.has("movement"):
			animate_movement(matching_combo.movement, matching_combo.movement_duration)
	
	if display_moves: 
		display_move(move)
		if matching_combo != null:
			highlight_display_combo(matching_combo.combo.length())
	

func validate_combo(moveset):
	var joined_moveset = "".join(moveset)
	for combo in combo_list:
		if combo.combo == joined_moveset:
			return combo
	

func reset_combo():
	combo.clear()
	

func display_move(character):
	var count = moves_container.get_child_count()
	var move = null
	
	if count < max_display_moves:
		move = Label.new()
		moves_container.add_child(move)
	else:
		move = moves_container.get_child(0)
		move.remove_theme_color_override("font_color")
		moves_container.move_child(move, count - 1)
	
	move.text = character.capitalize()
	

func highlight_display_combo(length):
	var count = moves_container.get_child_count()
	for i in range(length):
		moves_container.get_child(count - 1 - i).add_theme_color_override("font_color", Color.RED)
	

func is_jumping():
	return (Time.get_ticks_msec() - last_jump) <= jump_input_window * 1000
	

func hit(area, hitbox):
	if area is Hurtbox:
		var attack_info = light_attack_info
		
		if hitbox == upward_hitbox:
			attack_info = uppward_attack_info
		
		area.hit(attack_info)
	
	print("HIT: ", area)
	
	# VFX
	CameraShaker.shake(0.25, 0.2)
	
	#audio.play(hit_sounds.pick_random(), hitbox.global_position)
	

func animate_movement(local_vector : Vector3, duration : float):
	duration *= 1000
	var start_time = Time.get_ticks_msec()
	
	var global_vector = CameraEntity.main_camera.global_basis * local_vector
	
	# If body is grounded, flatten vector on floor
	if owner is CharacterBody3D and owner.is_on_floor():
		var plane = Plane(owner.get_floor_normal())
		global_vector = plane.project(global_vector).normalized() * global_vector.length()
		
	var start_pos = owner.global_position
	var target_pos = owner.global_position + global_vector
	DebugCanvas.debug_line(start_pos, target_pos, Color.PURPLE, 1.0, 2.0)
	
	# Test for physics collisions along path
	var body_test_result = PhysicsTestMotionResult3D.new()
	var params = PhysicsTestMotionParameters3D.new()
	params.from = owner.global_transform
	params.motion = global_vector
	
	# If collision occurs, set target_pos to the last position before collision
	if PhysicsServer3D.body_test_motion(owner.get_rid(), params, body_test_result):
		target_pos -= body_test_result.get_remainder()
	
	while(Time.get_ticks_msec() - start_time <= duration):
		var t = (Time.get_ticks_msec() - start_time) / duration
		owner.global_position = lerp(start_pos, target_pos, t)
		await get_tree().process_frame
	
	owner.global_position = target_pos
	
