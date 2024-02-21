extends Node3D

@export var light_attack_info = AttackInfo.new(5, 10, Vector3.FORWARD * 2)
@export var heavy_attack_info = AttackInfo.new(5, 10, Vector3.FORWARD * 2)
@export var uppward_attack_info = AttackInfo.new(5, 10, Vector3.UP * 6)

@export var combo_list = [
	{
		"state" : "light_1",
		"combo" : "l",
		#"movement" : Vector3(0, 0, -2),
		#"movement_duration" : 0.1,
	},
	{
		"state" : "light_2",
		"combo" : "ll",
		#"movement" : Vector3(0, 0, -2),
		#"movement_duration" : 0.1,
	},
	{
		"state" : "light_3",
		"combo" : "lll",
		#"movement" : Vector3(0, 0, -2),
		#"movement_duration" : 0.1,
	},
	{
		"state" : "heavy_1",
		"charge_state" : "heavy_1_charging",
		"combo" : "r",
	},
	{
		"state" : "heavy_2",
		"charge_state" : "heavy_2_charging",
		"combo" : "llr",
	},
	{
		"state" : "heavy_3",
		"charge_state" : "heavy_3_charging",
		"combo" : "lllr",
		"movement" : Vector3(0, 0, -6),
		"movement_duration" : 0.1,
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

@export var heavy_charged_duration = 2.00
@export var heavy_projectile_duration = 4.00

@onready var anim_tree : AnimationTree = $katana_pov_hands/AnimationTree
@onready var anim_state_machine : AnimationNodeStateMachinePlayback = anim_tree["parameters/playback"]
@onready var moves_container = $moves_display/moves_container

# Hitboxes
@onready var hitbox = $katana_pov_hands/first_person_rig/Skeleton3D/hand_r_attachment/hitbox
@onready var upward_hitbox = $katana_pov_hands/upward_hitbox

# VFX
@onready var charging_vfx = $katana_pov_hands/first_person_rig/Skeleton3D/hand_r_attachment/charging
@onready var projectile_charging_vfx = $katana_pov_hands/first_person_rig/Skeleton3D/hand_r_attachment/projectile_charging
@onready var decal_raycast = $decal_raycast
@onready var decal_prefab = $decal_prefab
@onready var blade_alignment = $katana_pov_hands/first_person_rig/Skeleton3D/hand_r_attachment/blade_alignment


var combo = []
var last_combo_addition = 0
var last_primary = -1
var last_secondary = -1
var last_jump = -1

var is_secondary_pressed = false
var secondary_press_start = -1

func _ready():
	hitbox.on_collision.connect(hit)
	upward_hitbox.on_collision.connect(hit)
	

func _process(delta):
	if not visible:
		return
	
	if UIManager.window_count() > 0:
		return
	
	if is_secondary_pressed:
		var time_pressed = Time.get_ticks_msec() - secondary_press_start
		var is_charged = time_pressed >= heavy_charged_duration * 1000
		var is_projectile = time_pressed >= heavy_projectile_duration * 1000
		
		if is_projectile:
			turn_on_charging_vfx(null)
		elif is_charged:
			turn_on_charging_vfx(projectile_charging_vfx)
		else:
			turn_on_charging_vfx(charging_vfx)
	
	if Input.is_action_just_pressed("jump"):
		last_jump = Time.get_ticks_msec()
	
	if Input.is_action_just_pressed("defend"):
		anim_state_machine.start("defend_start")
	# Primary attack is on press
	elif Input.is_action_just_pressed("attack_primary"):
		add_to_combo("l")
	# Secondary attack is on release
	elif Input.is_action_just_pressed("attack_secondary"):
		is_secondary_pressed = true
		secondary_press_start = Time.get_ticks_msec()
		
		var move = "r"
		if is_jumping():
			move = "j+r"
		
		# Test for valid combo without adding the move (will be added on release)
		var combo_copy = combo.duplicate()
		combo_copy.append(move)
		
		var matching_combo = validate_combo(combo_copy)
		
		# If no combo exists with the new move added,
		# start a new combo with only this move
		if matching_combo == null:
			combo_copy.clear()
			combo_copy.append(move)
			matching_combo = validate_combo(combo_copy)
		
		# Play charge state animation if a combo was found
		if matching_combo != null and matching_combo.has("charge_state"):
			anim_state_machine.start(matching_combo.charge_state)
		
	elif Input.is_action_just_released("attack_secondary"):
		is_secondary_pressed = false
		
		# Check charge time
		var time_pressed = Time.get_ticks_msec() - secondary_press_start
		var is_charged = time_pressed >= heavy_charged_duration * 1000
		var is_projectile = time_pressed >= heavy_projectile_duration * 1000
		
		if is_jumping():
			add_to_combo("j+r")
		else:
			add_to_combo("r")
		
		turn_on_charging_vfx(null)
	
	if not combo.is_empty() and not is_secondary_pressed and Time.get_ticks_msec() - last_combo_addition > combo_cancel_time * 1000:
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
	if matching_combo != null and matching_combo.has("state"):
		anim_state_machine.start(matching_combo.state)
		animation_changed(matching_combo.state)
		if matching_combo.has("movement"):
			animate_movement(matching_combo.movement, matching_combo.movement_duration)
		if display_moves: 
			display_move(move)
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
	if decal_raycast.is_colliding():
		create_decal(decal_raycast.get_collision_point(), blade_alignment.global_rotation, area)
	
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
	

func animation_changed(new_name):
	if new_name == "idle":
		hitbox.set_active(false)
		upward_hitbox.set_active(false)
	elif new_name in ["light_1", "light_2", "light_3", "heavy_1", "heavy_3"]:
		hitbox.clear_collisions() # Needed in case of attack to attack transition
		hitbox.set_active(true)
		upward_hitbox.set_active(false)
	elif new_name in ["heavy_2"]:
		upward_hitbox.clear_collisions() # Needed in case of attack to attack transition
		upward_hitbox.set_active(true)
		hitbox.set_active(false)
	

func turn_on_charging_vfx(particles):
	for vfx in [charging_vfx, projectile_charging_vfx]:
		vfx.emitting = vfx == particles
	

func create_decal(_position, _rotation, parent):
	var new_decal = decal_prefab.duplicate()
	new_decal.visible = true
	parent.add_child(new_decal)
	new_decal.global_position = _position
	new_decal.global_rotation = _rotation
	new_decal.fade_over.connect(free_decal.bind(new_decal))
	

func free_decal(decal):
	decal.queue_free
	
