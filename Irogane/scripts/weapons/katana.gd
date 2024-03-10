extends Node3D

@export var light_attack_info = AttackInfo.new(5, 10, Vector3.FORWARD * 2, ["bleed"])
@export var heavy_attack_info = AttackInfo.new(5, 10, Vector3.FORWARD * 2, ["bleed"])
@export var uppward_attack_info = AttackInfo.new(5, 10, Vector3.UP * 6)

@export var combo_list = [
	{
		"stance" : "rain stance",
		"state" : "light_1",
		"combo" : "l",
	},
	{
		"stance" : "rain stance",
		"state" : "light_2",
		"combo" : "ll",
	},
	{
		"stance" : "rain stance",
		"state" : "light_3",
		"combo" : "lll",
	},
	{
		"stance" : "rain stance",
		"state" : "heavy_1",
		"charge_state" : "heavy_1_charging",
		"combo" : "r",
	},
	{
		"stance" : "rain stance",
		"state" : "heavy_2",
		"charge_state" : "heavy_2_charging",
		"combo" : "llr",
	},
	{
		"stance" : "rain stance",
		"state" : "heavy_3",
		"charge_state" : "heavy_3_charging",
		"combo" : "lllr",
		"movement" : Vector3(0, 0, -6),
		"movement_duration" : 0.1,
	},
	{
		"stance" : "rain stance",
		"state" : "upward",
		"charge_state" : "upward_charging",
		"combo" : "j+r",
	},
	{
		"stance" : "lightning stance",
		"state" : "iaido_light_1",
		"combo" : "l",
		"movement" : Vector3(0, 0, -2),
		"movement_duration" : 0.1,
	},
	{
		"stance" : "lightning stance",
		"state" : "iaido_light_2",
		"combo" : "ll",
		"movement" : Vector3(0, 0, -2),
		"movement_duration" : 0.1,
	},
	{
		"stance" : "lightning stance",
		"state" : "iaido_light_3",
		"combo" : "lll",
		"movement" : Vector3(0, 0, -2),
		"movement_duration" : 0.1,
	},
	{
		"stance" : "lightning stance",
		"state" : "iaido_light_4",
		"combo" : "llll",
		"movement" : Vector3(0, 0, -2),
		"movement_duration" : 0.1,
	},
	{
		"stance" : "lightning stance",
		"state" : "heavy_3",
		"combo" : "r",
		"movement" : Vector3(0, 0, -12),
		"movement_duration" : 0.1,
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

# Skill Menu
@onready var ring_menu = $sword_ring_menu

# Hitboxes
@onready var hitbox = $katana_pov_hands/first_person_rig/Skeleton3D/hand_r_attachment/hitbox
@onready var upward_hitbox = $katana_pov_hands/upward_hitbox
@onready var guard_hitbox = $katana_pov_hands/first_person_rig/Skeleton3D/hand_r_attachment/guard_hitbox

# VFX
@onready var charging_vfx = $katana_pov_hands/first_person_rig/Skeleton3D/hand_r_attachment/charging
@onready var projectile_charging_vfx = $katana_pov_hands/first_person_rig/Skeleton3D/hand_r_attachment/projectile_charging
@onready var decal_raycast = $decal_raycast
@onready var decal_prefab = $decal_prefab
@onready var blade_alignment = $katana_pov_hands/first_person_rig/Skeleton3D/hand_r_attachment/blade_alignment
@onready var stance_label = $stance_label
@onready var trail_3d = $katana_pov_hands/first_person_rig/Skeleton3D/hand_r_attachment/blade_alignment/trail3d
@onready var guard_vfx = $katana_pov_hands/first_person_rig/Skeleton3D/hand_r_attachment/guard_vfx
@onready var perfect_guard_vfx = $katana_pov_hands/first_person_rig/Skeleton3D/hand_r_attachment/perfect_guard_vfx
@onready var slash_0_vfx = $katana_pov_hands/first_person_rig/Skeleton3D/hand_r_attachment/slash_0_vfx
@onready var slash_1_vfx = $katana_pov_hands/first_person_rig/Skeleton3D/hand_r_attachment/slash_0_vfx/slash_1_vfx
@onready var slash_circle_vfx = $katana_pov_hands/first_person_rig/Skeleton3D/hand_r_attachment/slash_0_vfx/slash_circle_vfx

var combo = []
var last_combo_addition = 0
var last_primary = -1
var last_secondary = -1
var last_jump = -1

var is_secondary_pressed = false
var secondary_press_start = -1

var is_guarding = false
var guard_start = null
var perfect_guard_window = 0.5

var current_skill = "rain stance"
var katana_skills : Array[String] = ["Focused", "Projectile"]
var katana_stances : Array[String] = ["Rain Stance", "River Stance", "Lightning Stance"]

var prev_animation = null

func _ready():
	hitbox.on_collision.connect(hit)
	hitbox.on_block.connect(hit_guarded)
	upward_hitbox.on_collision.connect(hit)
	upward_hitbox.on_block.connect(hit_guarded)
	
	guard_hitbox.on_guard.connect(guarded)
	guard_hitbox.on_perfect_guard.connect(perfect_guarded)
	
	ring_menu.item_selected.connect(skill_selected)
	
	InputContextManager.context_changed.connect(context_changed)
	

func _process(delta):
	if not visible:
		return
	
	animation_change_check()
	
	# Close ring menu if open
	if InputContextManager.is_ring_menu_context():
		if ring_menu.visible and not Input.is_action_pressed("ring_menu"):
			ring_menu.close()
			InputContextManager.switch_context(InputContextType.GAME)
	
	if not InputContextManager.is_game_context():
		return
	
	# Open ring menu
	if Input.is_action_just_pressed("ring_menu") and not ring_menu.visible:
		#var ring_items: Array = PlayerEntity.get_skills_in_tree("sword")
		if katana_stances:
			ring_menu.initialize_items(katana_stances)
			ring_menu.open()
			return
	
	# Update charging vfx
	if is_secondary_pressed:
		var time_pressed = Time.get_ticks_msec() - secondary_press_start
		var is_charged = time_pressed >= heavy_charged_duration * 1000
		var is_projectile = time_pressed >= heavy_projectile_duration * 1000
		
		if is_projectile and can_projectile(): # Projectile charged
			turn_on_charging_vfx(null)
		elif is_charged and can_projectile(): # Projectile vfx
			turn_on_charging_vfx(projectile_charging_vfx)
		elif can_focus(): # Focus vfx
			turn_on_charging_vfx(charging_vfx)
	
	if Input.is_action_just_pressed("jump"):
		last_jump = Time.get_ticks_msec()
	
	if Input.is_action_just_released("defend") and is_guarding:
		stop_guard()
		anim_state_machine.start("idle")
	
	if Input.is_action_just_pressed("defend"):
		start_guard()
		anim_state_machine.start("defend")
	# Primary attack is on press
	elif Input.is_action_just_pressed("attack_primary"):
		add_to_combo("l")
	# If no charging, secondary attack is on press.
	# Otherwise, it's on release
	if can_focus() or can_projectile():
		if Input.is_action_just_pressed("attack_secondary"):
			charge_secondary_attack()
		# Check is_secondary_pressed to avoid attacking when key 
		# is pressed in UI context and realeased in game context
		elif Input.is_action_just_released("attack_secondary") and is_secondary_pressed:
			execute_secondary_attack()
	else:
		if Input.is_action_just_pressed("attack_secondary"):
			execute_secondary_attack()
	
	if not combo.is_empty() and not is_secondary_pressed and Time.get_ticks_msec() - last_combo_addition > combo_cancel_time * 1000:
		reset_combo()
	

func charge_secondary_attack():
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
	

func execute_secondary_attack():
	is_secondary_pressed = false
	
	# Check charge time
	var time_pressed = Time.get_ticks_msec() - secondary_press_start
	var is_charged = can_focus() and time_pressed >= heavy_charged_duration * 1000
	var is_projectile = can_projectile() and time_pressed >= heavy_projectile_duration * 1000
	
	if is_jumping():
		add_to_combo("j+r")
	else:
		add_to_combo("r")
	
	turn_on_charging_vfx(null)
	

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
		# Skip stance based combos if not in relevant state
		if combo.has("stance"):
			if combo.stance != current_skill:
				continue
		
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
	
	slash_0_vfx.emit_particle(blade_alignment.global_transform, Vector3.ZERO, Color.WHITE, Color.WHITE, 1)
	slash_1_vfx.emit_particle(blade_alignment.global_transform, Vector3.ZERO, Color.WHITE, Color.WHITE, 1)
	slash_circle_vfx.emit_particle(blade_alignment.global_transform, Vector3.ZERO, Color.WHITE, Color.WHITE, 1)
	
	#audio.play(hit_sounds.pick_random(), hitbox.global_position)
	

func hit_guarded(area : Guardbox, hitbox):
	if area.is_perfect:
		CameraShaker.shake(0.5, 0.2)
	else:
		CameraShaker.shake(0.25, 0.2)
	
	var attack_info = light_attack_info
	if hitbox == upward_hitbox:
		attack_info = uppward_attack_info
	area.guard(attack_info, hitbox)
	
	play_guard_vfx(hitbox.global_position)
	anim_state_machine.start("idle")
	

func guarded(attack_info, hitbox):
	anim_state_machine.start("guard_hit")
	play_guard_vfx(hitbox.global_position + Vector3.UP * 0.1)
	

func perfect_guarded(attack_info, hitbox):
	var pos = hitbox.global_position + Vector3.UP * 0.1
	anim_state_machine.start("guard_hit")
	play_guard_vfx(pos)
	play_perfect_guard_vfx(pos)
	

func play_guard_vfx(_position):
	CameraShaker.shake(0.25, 0.2)
	guard_vfx.global_position = _position
	guard_vfx.restart()
	

func play_perfect_guard_vfx(_position):
	CameraShaker.shake(0.25, 0.2)
	perfect_guard_vfx.global_position = _position
	perfect_guard_vfx.restart()
	

func animate_movement(local_vector : Vector3, duration : float):
	duration *= 1000
	var start_time = Time.get_ticks_msec()
	
	var global_vector = CameraEntity.main_camera.global_basis * local_vector
	
	# If body is grounded, flatten vector on floor
	if owner is CharacterBody3D and owner.is_on_floor():
		var plane = Plane(owner.get_floor_normal())
		global_vector = plane.project(global_vector).normalized() * local_vector.length()
		
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
	

func animation_change_check():
	var current_animation = anim_state_machine.get_current_node()
	if current_animation != prev_animation:
		animation_changed(current_animation)
	prev_animation = current_animation
	

func animation_changed(new_name):
	if new_name == "idle":
		hitbox.set_active(false)
		upward_hitbox.set_active(false)
		set_trail_enabled(false)
	elif new_name in ["light_1", "light_2", "light_3", "heavy_1", "heavy_3", 
	"iaido_light_1", "iaido_light_2", "iaido_light_3", "iaido_light_4",]:
		hitbox.clear_collisions() # Needed in case of attack to attack transition
		hitbox.set_active(true)
		upward_hitbox.set_active(false)
		set_trail_enabled(true)
	elif new_name in ["heavy_2"]:
		upward_hitbox.clear_collisions() # Needed in case of attack to attack transition
		upward_hitbox.set_active(true)
		hitbox.set_active(false)
		set_trail_enabled(true)
	

func turn_on_charging_vfx(particles):
	for vfx in [charging_vfx, projectile_charging_vfx]:
		vfx.emitting = vfx == particles
	

func set_trail_enabled(state):
	if trail_3d:
		trail_3d.trailEnabled = state
	

func create_decal(_position, _rotation, parent):
	var new_decal = decal_prefab.duplicate()
	new_decal.visible = true
	parent.add_child(new_decal)
	new_decal.global_position = _position
	new_decal.global_rotation = _rotation
	new_decal.fade_over.connect(free_decal.bind(new_decal))
	

func free_decal(decal):
	decal.queue_free
	

func skill_selected(skill_name):
	current_skill = skill_name.to_lower()
	
	if "stance" in current_skill:
		enter_stance(skill_name)
	

func enter_stance(stance_name):
	# Combo should not carry between stances
	reset_combo()
	
	# Animate stance ui
	stance_label.show_text(stance_name + " entered")
	
	# Stance animation
	

func exit_stance():
	# Animate stance ui
	stance_label.show_text("Stance Broken")
	

func is_move_input_pressed():
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var is_jumping = Input.is_action_just_pressed("jump")
	return input_dir.length() != 0 or is_jumping
	

func fetch_skills():
	var skills: Array = PlayerEntity.get_skills_in_tree("sword")
	for skill in skills:
		if "stance" in skill.to_lower():
			katana_stances.append(skill)
		else:
			katana_skills.append(skill)
	

func can_focus():
	return  "Focused" in katana_skills
	

func can_projectile():
	return  "Projectile" in katana_skills
	

func context_changed(old_context, new_context):
	# In case context changed, we cancel the ring menu without activating a skill
	if old_context == InputContextType.RING_MENU and new_context != old_context:
		if ring_menu.visible == true:
			ring_menu.close_no_signal()
	

func start_guard():
	is_guarding = true
	guard_start = Time.get_ticks_msec()
	guard_hitbox.set_active(true)
	guard_hitbox.set_perfect(perfect_guard_window)
	

func stop_guard():
	is_guarding = false
	guard_hitbox.set_active(false)
	
