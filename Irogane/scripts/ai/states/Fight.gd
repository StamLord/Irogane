extends NpcState
class_name Fight

@onready var anim_tree : AnimationTree = $"../../character_body/katana_pov_hands/AnimationTree"
@onready var anim_state_machine : AnimationNodeStateMachinePlayback

@onready var hitbox = $"../../character_body/katana_pov_hands/first_person_rig/Skeleton3D/hand_r_attachment/hitbox"
@onready var guard_hitbox = $"../../character_body/katana_pov_hands/first_person_rig/Skeleton3D/hand_r_attachment/guard_hitbox"
@onready var trail_3d = $"../../character_body/katana_pov_hands/first_person_rig/Skeleton3D/hand_r_attachment/blade_alignment/trail3d"
@onready var guard_break_vfx = $"../../character_body/vfx/guard_break"

@onready var audio = $"../../character_body/katana_pov_hands/first_person_rig/Skeleton3D/hand_r_attachment/blade_alignment/audio"
const swing_sfx = [preload("res://assets/audio/katana/katana_swoosh_01.mp3"), preload("res://assets/audio/katana/katana_swoosh_02.mp3"), preload("res://assets/audio/katana/katana_swoosh_03.mp3"), preload("res://assets/audio/katana/katana_swoosh_04.mp3")]
const clash_sfx = [preload("res://assets/audio/katana/katana_clash_01.mp3"), preload("res://assets/audio/katana/katana_clash_02.mp3"), preload("res://assets/audio/katana/katana_clash_03.mp3"), preload("res://assets/audio/katana/katana_clash_04.mp3")]
const hit_sfx = [preload("res://assets/audio/katana/katana_hit_01.ogg")]

@export var light_attack_info = AttackInfo.new(25, 10, false, Vector3.FORWARD * 2)
@export var heavy_attack_info = AttackInfo.new(45, 10, DamageType.SLASH, true, Vector3.FORWARD * 10)

@export var attack_range = 1.0
@export var retreat_range = 4.0
@export var circle_range = 4.0
var attack_target : Node
var target_weapon_manager: WeaponManager

var defend_timer = Timer.new()

var is_attacking = false
var is_waiting = false
var is_defending = false
var is_retreating = false

var perfect_guard_window = 0.5
var guard_break_duration = 3.0

var aggressive = 2 # Chance to attack when in range [4 = 100%, 3 = 75%, 2 = 50%, 1 = 25%, 0 = 0%]
var defensive = 3 # Chance to defend when not attacking [4 = 100%, 3 = 75%, 2 = 50%, 1 = 25%, 0 = 0%]
var reflexes = 2 # Chance to defend when attacked [4 = 100%, 3 = 75%, 2 = 50%, 1 = 25%, 0 = 0%]

var attack_sequence = 0
var max_attack_sequence_window = 2.0
var last_attack_time = 0.0

var retreat_value = 0 # At 10 it's 100% to retreat

var prev_animation = null

# Target seeing
var lost_target = false
var lost_target_time = 0.0

func _ready():
	hitbox.on_collision.connect(hit)
	hitbox.on_block.connect(hit_blocked)
	hitbox.add_ignore(owner)
	
	guard_hitbox.on_guard.connect(guarded)
	guard_hitbox.on_perfect_guard.connect(perfect_guarded)
	
	add_child(defend_timer)
	defend_timer.one_shot = true
	defend_timer.timeout.connect(finished_defense)
	

func enter(state_machine):
	if anim_tree:
		anim_state_machine = anim_tree["parameters/playback"]
	
	lost_target = false
	#attack_target = get_from_blackboard("attack_target")
	attack_target = PlayerEntity.player_node
	
	target_weapon_manager = attack_target.get_node("%weapon_manager")
	if target_weapon_manager:
		target_weapon_manager.on_attack.connect(try_defend)
	
	state_machine.awareness_agent.on_enemy_seen.connect(enemy_seen)
	state_machine.awareness_agent.on_enemy_lost.connect(enemy_lost)
	
	state_machine.pathfinding.set_override_movement_speed(movement_speed)
	state_machine.pathfinding.set_override_rotation_speed(rotation_speed)
	state_machine.pathfinding.look_at_target_while_moving = true
	

func physics_update(state_machine, _delta):
	if attack_target == null:
		print("%s: Fight target is null. This shouldn't happen!", name)
		Transitioned.emit(self, "idle")
		return
	
	animation_change_check()
	
	if is_attacking or get_stats().is_staggered: # Exit before rotation
		return
	
	# Reset attack sequence
	if Time.get_ticks_msec() - last_attack_time >= max_attack_sequence_window * 1000:
		attack_sequence = 0
	 
	# Face target
	set_target_rotation(attack_target.global_position)
	
	# Keep distance
	if is_retreating:
		if not is_in_range(retreat_range):
			DebugCanvas.debug_text("Not in Retreat Range", state_machine.pathfinding.global_position + Vector3.UP * 2, Color.RED)
			move_to_range(retreat_range)
		else:
			circle_target(retreat_range)
	# Close distance
	elif not is_in_range(attack_range):
		DebugCanvas.debug_text("Not in Attack Range", state_machine.pathfinding.global_position + Vector3.UP * 2, Color.RED)
		move_to_range(attack_range)
	else:
		circle_target(attack_range)
	
	# Decide next action only when in range
	if not is_in_range(attack_range):
		return
	
	if randi_range(0, 100) < aggressive * 25: # aggresive 4 = 100%, 3 = 75%, 2 = 50%, 1 = 25%, 0 = 0%
		execute_attack()
		DebugCanvas.debug_text("ATTACK", state_machine.pathfinding.global_position + Vector3.UP * 2, Color.RED, 1.0)
	elif randi_range(0, 100) < defensive * 25: # defensive 4 = 100%, 3 = 75%, 2 = 50%, 1 = 25%, 0 = 0%
		execute_defense()
		DebugCanvas.debug_text("DEFEND", state_machine.pathfinding.global_position + Vector3.UP * 2, Color.GREEN, 1.0)
	elif randi_range(0, 10) < retreat_value:
		execute_retreat()
		DebugCanvas.debug_text("RETREAT", state_machine.pathfinding.global_position + Vector3.UP * 2, Color.CYAN, 1.0)
	else:
		execute_wait()
		DebugCanvas.debug_text("WAIT", state_machine.pathfinding.global_position + Vector3.UP * 2, Color.BLUE, 1.0)
	

func is_in_range(range):
	if attack_target and state_machine and state_machine.pathfinding:
		var dist = attack_target.global_position - state_machine.pathfinding.global_position
		return abs(dist.length() - range) <= 0.2
	
	return false
	

func move_to_range(range):
	var body = state_machine.pathfinding
	var dir_to_self = (body.global_position - attack_target.global_position).normalized()
	var target_pos = attack_target.global_position + dir_to_self * range * 0.8
	set_target_position(target_pos)
	

func circle_target(range):
	var body = state_machine.pathfinding
	var dir_to_self = (body.global_position - attack_target.global_position).normalized()
	var rotated_dir = dir_to_self.rotated(Vector3.UP, deg_to_rad(10))
	var target_pos = attack_target.global_position + rotated_dir * range * 0.8
	set_target_position(target_pos)
	

func execute_attack():
	is_attacking = true
	
	if anim_state_machine:
		# Execute a heavy attack every 4th time or if not in attack sequence 33% of the time
		if attack_sequence >= 2 or attack_sequence == 0 and randi_range(0, 2) == 0: 
			anim_state_machine.start("heavy_3")
			attack_sequence = 0
			retreat_value += 2
			await get_tree().create_timer(1.5).timeout
		# Otherwise a light attack
		else:
			anim_state_machine.start("light_" + str(attack_sequence + 1)) # play light_1, light_2 or light_3
			attack_sequence += 1
			retreat_value += 1
			last_attack_time = Time.get_ticks_msec()
			await get_tree().create_timer(0.5).timeout
	
	is_attacking = false
	

func animation_change_check():
	var current_animation = anim_state_machine.get_current_node()
	if current_animation != prev_animation:
		animation_changed(current_animation)
	prev_animation = current_animation
	

func animation_changed(new_name):
	var is_heavy = new_name in ["heavy_1", "heavy_2", "heavy_3"]
	if new_name == "idle":
		hitbox.set_active(false)
		set_trail_enabled(false)
	elif new_name in ["light_1", "light_2", "light_3", "heavy_1", "heavy_2", "heavy_3", 
	"iaido_light_1", "iaido_light_2", "iaido_light_3", "iaido_light_4",]:
		hitbox.clear_collisions() # Needed in case of attack to attack transition
		hitbox.set_active(true)
		hitbox.set_heavy(is_heavy)
		set_trail_enabled(true)
	

func set_trail_enabled(state):
	if trail_3d:
		trail_3d.trailEnabled = state
	

func execute_wait():
	is_waiting = true
	await get_tree().create_timer(1.0).timeout
	is_waiting = false
	

func try_defend():
	if is_attacking or get_stats().is_staggered:
		return
	
	if randi_range(0, 100) <= reflexes * 25: # 4 = 100%, 3 = 75%, 2 = 50%, 1 = 25%, 0 = 0%
		execute_defense()
	

func execute_defense():
	if not is_defending: # Avoid restarting if already defending
		#await get_tree().create_timer((4 - reflexes) * 0.25).timeout
		if anim_state_machine:
			anim_state_machine.start("defend")
		is_defending = true
		guard_hitbox.set_active(true)
		guard_hitbox.set_perfect(perfect_guard_window)
	
	defend_timer.start(1.0) # Will restart an already running timer


func finished_defense():
	anim_state_machine.start("idle")
	guard_hitbox.set_active(false)
	is_defending = false
	

func execute_retreat():
	retreat_value = 0
	is_retreating = true
	await get_tree().create_timer(4.0).timeout
	is_retreating = false
	

func guarded(attack_info, hitbox):
	anim_state_machine.start("guard_hit")
	# TODO: Add audio & vfx
	
	if get_stats():
		get_stats().deplete_stamina(attack_info.soft_damage)
		if get_stats().stamina.get_value() <= 0:
			guard_break()
	

func perfect_guarded(attack_info, hitbox):
	var pos = hitbox.global_position + Vector3.UP * 0.1
	anim_state_machine.start("guard_hit")
	# TODO: Add audio & vfx
	

func guard_break():
	defend_timer.stop()
	finished_defense()
	
	retreat_value += 2
	
	# Play vfx
	guard_break_vfx.restart()
	
	get_stats().is_guard_broken = true
	await get_tree().create_timer(guard_break_duration).timeout
	get_stats().is_guard_broken = false
	

func hit(area, hitbox):
	if area is Hurtbox:
		area.hit(get_attack_info(hitbox))
		play_audio(hit_sfx.pick_random())
	

func hit_blocked(area : Guardbox, hitbox):
	if area.is_perfect:
		get_stats().got_perfect_blocked()
	
	area.guard(get_attack_info(hitbox), hitbox)
	anim_state_machine.start("idle")
	play_audio(clash_sfx.pick_random())
	#play_guard_vfx(hitbox.global_position)
	

func get_attack_info(hitbox : Hitbox):
	var attack_info = heavy_attack_info if hitbox.is_heavy else light_attack_info
	return attack_info.get_translated(state_machine.pathfinding.global_basis)
	

func exit(state_machine):
	state_machine.awareness_agent.on_enemy_seen.disconnect(enemy_seen)
	state_machine.awareness_agent.on_enemy_lost.disconnect(enemy_lost)
	
	state_machine.pathfinding.clear_override_movement_speed()
	state_machine.pathfinding.clear_override_rotation_speed()
	state_machine.pathfinding.look_at_target_while_moving = false
	
	if target_weapon_manager:
		target_weapon_manager.on_attack.disconnect(try_defend)
		target_weapon_manager = null
	

func enemy_lost(enemy):
	if enemy == attack_target:
		lost_target = true
		lost_target_time = Time.get_ticks_msec()
	

func enemy_seen(enemy):
	if enemy == attack_target and lost_target:
		lost_target = false
#		DebugCanvas.debug_text("Enemy Regained ", state_machine.pathfinding.global_position, Color.PURPLE, 3)
	

func play_audio(clip):
	if audio:
		audio.stream = clip
		audio.play()
	

#func switch_to_search_state():
	#set_in_blackboard("search_target", chase_target)
	#set_in_blackboard("search_last_seen_position", chase_target.global_position)
	#set_in_blackboard("search_last_direction", chase_target_last_direction)
	#Transitioned.emit(self, "search")
	
