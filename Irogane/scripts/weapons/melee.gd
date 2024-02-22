extends Node3D

@export var valid_states_for_input = ["idle", "chain"]
@export var combo_cancel_time = 1
@export var combo_list = [
	{
		"state" : "flurry",
		"combo" : "lrlrlr",
		"final" : true
	},
	{
		"state" : "left_elbow",
		"combo" : "ll",
		"final" : true
	},
	{
		"state" : "right_elbow",
		"combo" : "rr",
		"final" : false
	},
	{
		"state" : "right_elbow_2",
		"combo" : "rrr",
		"final" : true
	},
]

@export var double_input_window = 0.1
@export var jump_input_window = 0.25

@export var display_moves = true
@export var max_display_moves = 10

@export var light_attack_info = AttackInfo.new(5, 10, Vector3.FORWARD * 2)
@export var uppercut_attack_info = AttackInfo.new(10, 15, Vector3.UP * 6)

@onready var vault = $"../../../../states/vault"
@onready var air = $"../../../../states/air"
@onready var swim = $"../../../../states/swim"
@onready var climb_rope = $"../../../../states/climb_rope"
@onready var glide = $"../../../../states/glide"

const anim_idle_path = "parameters/StateMachine/idle"
@onready var anim_tree : AnimationTree = $first_person_rig/AnimationTree
@onready var anim_state_machine : AnimationNodeStateMachinePlayback = anim_tree["parameters/StateMachine/playback"]
@onready var anim_idle_state_machine : AnimationNodeStateMachinePlayback = anim_tree[anim_idle_path + "/playback"]
@onready var anim_hands_ik = $first_person_rig

@onready var moves_container = $moves_display/moves_container

@onready var hitbox_l = $first_person_rig/RootNode/first_person_rig/Skeleton3D/left_hand_attach/hitbox
@onready var hitbox_r = $first_person_rig/RootNode/first_person_rig/Skeleton3D/right_hand_attach/hitbox
@onready var hitbox_elbow_l = $first_person_rig/RootNode/first_person_rig/Skeleton3D/left_elbow_attach/hitbox
@onready var hitbox_elbow_r = $first_person_rig/RootNode/first_person_rig/Skeleton3D/right_elbow_attach/hitbox
@onready var hitbox_uppercut = $first_person_rig/uppercut_hitbox

@onready var hit_vfx = $hit_vfx
@onready var ripple_vfx = $ripple_vfx

@onready var audio = $audio

var combo = []
var last_combo_addition = 0

var is_swimming = false
var is_climb_rope = false

var last_swim_input = Vector2.ZERO

var last_primary = -1
var last_secondary = -1
var last_jump = -1

@onready var hit_sounds = [
	preload ("res://assets/audio/melee/hit07.mp3"), 
	preload ("res://assets/audio/melee/hit08.mp3"), 
	preload ("res://assets/audio/melee/hit09.mp3"), 
	preload ("res://assets/audio/melee/hit16.mp3")]

func _ready():
	# Register to hitboxes
	hitbox_l.on_collision.connect(hit)
	hitbox_r.on_collision.connect(hit)
	hitbox_elbow_l.on_collision.connect(hit)
	hitbox_elbow_r.on_collision.connect(hit)
	hitbox_uppercut.on_collision.connect(hit)
	
	# Register to states
	air.air_started.connect(start_animate_air)
	air.air_ended.connect(stop_animate_air)
	
	vault.vault_started.connect(start_animate_vault)
	vault.vault_ended.connect(stop_animate_vault)
	
	swim.swim_started.connect(start_animate_swim)
	swim.swim_ended.connect(stop_animate_swim)
	
	climb_rope.climb_rope_started.connect(start_animate_climb_rope)
	climb_rope.climb_rope_ended.connect(stop_animate_climb_rope)
	
	glide.glide_started.connect(start_animate_glide)
	glide.glide_ended.connect(stop_animate_glide)
	

func _process(delta):
	if not visible:
		return
		
	if is_swimming:
		# Smooth the swim input to avoid instant direction shift
		last_swim_input = lerp(last_swim_input, swim.input_dir, delta * 10)
		
		# Lerp between both all input and only forward input, based on the forward input
		# This way, moving both forward and sideways will show only forward animation
		# to avoid wierd in-between animations.
		var vector = lerp(Vector2(last_swim_input.x, -last_swim_input.y), Vector2(0, -last_swim_input.y), abs(last_swim_input.y))
		
		anim_tree[anim_idle_path + "/swim/blend/blend_position"] = vector
	elif is_climb_rope:
		anim_tree[anim_idle_path + "/climb_rope/blend/blend_amount"] = climb_rope.vertical_direction
	
	if UIManager.window_count() < 1:
		if Input.is_action_just_pressed("jump"):
			last_jump = Time.get_ticks_msec()
		
		if Input.is_action_just_pressed("defend"):
			anim_state_machine.start("defend_start")
			add_to_combo("d")
		elif anim_state_machine.get_current_node() == "defend" and not Input.is_action_pressed("defend"):
			anim_state_machine.travel("idle")
		elif Input.is_action_just_pressed("attack_primary"):
			#if valid_state_for_input():
			last_primary = Time.get_ticks_msec()
			if is_primary_and_secondary():
				anim_state_machine.start("double_punch")
				add_to_combo("l+r")
			else:
				anim_state_machine.start("left")
				add_to_combo("l")
		elif Input.is_action_just_pressed("attack_secondary"):
			#if valid_state_for_input():
			last_secondary = Time.get_ticks_msec()
			
			if is_primary_and_secondary():
				anim_state_machine.start("double_punch")
				add_to_combo("l+r")
			elif is_jumping():
				anim_state_machine.start("uppercut")
				add_to_combo("j+r")
			else:
				anim_state_machine.start("right")
				add_to_combo("r")
	
	if not combo.is_empty() and Time.get_ticks_msec() - last_combo_addition > combo_cancel_time * 1000:
		reset_combo()
	

func add_to_combo(move):
	combo.append(move)
	last_combo_addition = Time.get_ticks_msec()
	
	var matching_combo = validate_combo(combo)
	#print(matching_combo)
	
	if matching_combo != null:
		anim_state_machine.start(matching_combo.state)
		# If final, combo is reset and additional moves start a new combo
		# If not final, aditional moves can add up to a bigger combo
		if matching_combo.final:
			reset_combo()
	
	if display_moves: 
		display_move(move)
		if matching_combo != null:
			highlight_display_combo(matching_combo.combo.length())
	

func is_primary_and_secondary():
	var both_pressed = Input.is_action_just_pressed("attack_primary") and Input.is_action_just_pressed("attack_secondary")
	var pressed_in_succession = abs(last_primary - last_secondary) <= double_input_window * 1000
	return both_pressed or pressed_in_succession
	

func is_jumping():
	return (Time.get_ticks_msec() - last_jump) <= jump_input_window * 1000
	

func reset_combo():
	combo.clear()
	

func valid_state_for_input():
	var state = anim_state_machine.get_current_node()
	for valid in valid_states_for_input:
		if valid in state:
			return true
	return false
	

func validate_combo(combo):
	#print(combo)
	var matching_combos = []
	for c in combo_list:
		var move_size = c.combo.length()
		# Our combo can't contain these moves
		if move_size > combo.size():
			continue
		# Compare moves from last to first
		var matching = true
		for i in range(move_size):
			# Not the same
			if c.combo[move_size - 1 - i] != combo[combo.size() - 1 - i]:
				matching = false
				break
		if matching:
			matching_combos.append(c)
	
	# No matches found
	if matching_combos.is_empty():
		return null
	
	# Return the only match
	if matching_combos.size() == 1:
		return matching_combos[0]
	
	# Return the longest matching combo
	var longest_combo = null
	var length = 0
	for c in matching_combos:
		if c.combo.length() > length:
			length = c.combo.length()
			longest_combo = c
	
	return longest_combo
	

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
	

func hit(area, hitbox):
	if area is Hurtbox:
		var attack_info = null
		
		if hitbox == hitbox_uppercut:
			attack_info = uppercut_attack_info.clone()
		else:
			attack_info = light_attack_info.clone()
			attack_info.force = get_global_transform().basis * attack_info.force
		
		area.hit(attack_info)
		
		CameraShaker.shake(0.25, 0.2)
		hit_vfx.global_position = hitbox.global_position
		hit_vfx.emit_particle(hit_vfx.global_transform, Vector3.ZERO, Color.WHITE, Color.WHITE, 1)
		ripple_vfx.global_position = hitbox.global_position
		ripple_vfx.emit_particle(ripple_vfx.global_transform, Vector3.ZERO, Color.WHITE, Color.WHITE, 1)
		
		audio.play(hit_sounds.pick_random(), hitbox.global_position)
	

func start_animate_air():
	anim_idle_state_machine.travel("air")
	anim_tree["parameters/StateMachine/idle/conditions/is_air"] = true
	

func stop_animate_air():
	anim_idle_state_machine.travel("idle")
	anim_tree["parameters/StateMachine/idle/conditions/is_air"] = false
	

func start_animate_vault(ledge_position):
	anim_state_machine.start("open_hands")
	anim_hands_ik.start_ik()
	var hand_offset = global_transform.basis * Vector3.RIGHT * 0.25
	anim_hands_ik.set_targets(ledge_position - hand_offset, ledge_position + hand_offset)
	

func stop_animate_vault(_ledge_position):
	anim_state_machine.start("idle")
	anim_hands_ik.stop_ik()
	

func start_animate_swim():
	anim_idle_state_machine.travel("swim")
	is_swimming = true
	anim_tree[anim_idle_path + "/conditions/is_swim"] = true
	

func stop_animate_swim():
	anim_idle_state_machine.travel("idle")
	is_swimming = false
	anim_tree[anim_idle_path + "/conditions/is_swim"] = false
	

func start_animate_climb_rope():
	anim_idle_state_machine.travel("climb_rope")
	is_climb_rope = true
	anim_tree[anim_idle_path + "/conditions/is_climb_rope"] = true
	

func stop_animate_climb_rope():
	anim_idle_state_machine.travel("idle")
	is_climb_rope = false
	anim_tree[anim_idle_path + "/conditions/is_climb_rope"] = false
	

func start_animate_glide():
	anim_idle_state_machine.travel("glide")
	anim_tree[anim_idle_path + "/conditions/is_glide"] = true
	

func stop_animate_glide():
	anim_idle_state_machine.travel("idle")
	anim_tree[anim_idle_path + "/conditions/is_glide"] = false
	
