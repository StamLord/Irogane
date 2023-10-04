extends Node3D

@export var valid_states_for_input = ["idle", "chain"]
@export var combo_cancel_time = 1
@export var combo_list = [
	{
		"state" : "flurry",
		"combo" : "lrlrlr"
	},
	{
		"state" : "left_elbow",
		"combo" : "ll"
	},
	{
		"state" : "right_elbow",
		"combo" : "rr"
	},
]

@export var display_moves = true
@export var max_display_moves = 10

@onready var vault = $"../../../../../../../states/vault"
@onready var anim_tree : AnimationTree = $first_person_rig/AnimationTree
@onready var anim_state_machine : AnimationNodeStateMachinePlayback = anim_tree["parameters/StateMachine/playback"]
@onready var anim_hands_ik = $first_person_rig

@onready var moves_container = $moves_display/moves_container

var combo = ""
var last_combo_addition = 0

func _ready():
	vault.vault_started.connect(start_animate_vault)
	vault.vault_ended.connect(stop_animate_vault)

func _process(delta):
	
	if Input.is_action_just_pressed("defend"):
		anim_state_machine.start("defend_start")
		add_to_combo("d")
	elif anim_state_machine.get_current_node() == "defend" and not Input.is_action_pressed("defend"):
		anim_state_machine.start("idle")
	elif Input.is_action_just_pressed("attack_primary"):
		#if valid_state_for_input():
		anim_state_machine.start("left")
		add_to_combo("l")
	elif Input.is_action_just_pressed("attack_secondary"):
		#if valid_state_for_input():
		var state = anim_state_machine.get_current_node()
		if state == "right_elbow":
			anim_state_machine.start("right_elbow_2")
		else:
			anim_state_machine.start("right")
		add_to_combo("r")
	
	if not combo.is_empty() and Time.get_ticks_msec() - last_combo_addition > combo_cancel_time * 1000:
		reset_combo()
	
func add_to_combo(move):
	combo += move
	last_combo_addition = Time.get_ticks_msec()
	
	var matching_combo = validate_combo(combo)
	print(matching_combo)
	
	if matching_combo != null:
		anim_state_machine.start(matching_combo.state)
		reset_combo()
	
	if display_moves: 
		display_move(move)
		if matching_combo != null:
			highlight_display_combo(matching_combo.combo.length())
		
func reset_combo():
	combo = ""

func valid_state_for_input():
	var state = anim_state_machine.get_current_node()
	for valid in valid_states_for_input:
		if valid in state:
			return true
	return false

func validate_combo(combo):
	print(combo)
	var matching_combos = []
	for c in combo_list:
		var move_size = c.combo.length()
		# Our combo can't contain these moves
		if move_size > combo.length():
			continue
		# Compare moves from last to first
		var matching = true
		for i in range(move_size):
			# Not the same
			if c.combo[move_size - 1 - i] != combo[combo.length() - 1 - i]:
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

func display_move(char):
	var count = moves_container.get_child_count()
	var move = null
	
	if count < max_display_moves:
		move = Label.new()
		moves_container.add_child(move)
	else:
		move = moves_container.get_child(0)
		move.remove_theme_color_override("font_color")
		moves_container.move_child(move, count - 1)
	
	move.text = char.capitalize()

func highlight_display_combo(length):
	var count = moves_container.get_child_count()
	for i in range(length):
		moves_container.get_child(count - 1 - i).add_theme_color_override("font_color", Color.RED)

func start_animate_vault(ledge_position):
	anim_state_machine.start("open_hands")
	anim_hands_ik.start_ik()
	var hand_offset = global_transform.basis * Vector3.RIGHT * 0.25
	anim_hands_ik.set_targets(ledge_position - hand_offset, ledge_position + hand_offset)

func stop_animate_vault(ledge_position):
	anim_state_machine.start("idle")
	anim_hands_ik.stop_ik()
