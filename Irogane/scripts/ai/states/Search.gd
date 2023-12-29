extends NpcState
class_name Search

@export var search_duration = 20.0
@export var search_range = 10.0
@export var extrapolate_movement_range = 4.0
@export var wait_at_search_point = 3.0
@export var cheat_amount = 4.0

var search_target = null
var last_seen_position = Vector3.ZERO
var last_direction = Vector3.ZERO

func enter(state_machine):
	search_target = get_from_blackboard("search_target") 					# Used for cheating 
	last_seen_position = get_from_blackboard("search_last_seen_position") 	# Searching around this point
	last_direction = get_from_blackboard("search_last_direction")			# Used to nudge search in direction
	
	state_machine.awareness_agent.on_enemy_seen.connect(enemy_seen)
	state_machine.awareness_agent.on_sound_heard.connect(sound_heard)
	
	state_machine.pathfinding.set_override_movement_speed(movement_speed)
	state_machine.pathfinding.set_override_rotation_speed(rotation_speed)
	
	var target = last_seen_position
	
	# Extrapolated search position based on last direction, if provided
	if last_direction != null:
		target += last_direction * extrapolate_movement_range
	
	set_target_position(target)
	state_machine.pathfinding.nav.navigation_finished.connect(reached_search_point)
	

func physics_update(state_machine, _delta):
	# Search timeout
	if Time.get_ticks_msec() - enter_time > search_duration * 1000:
#		DebugCanvas.debug_text("Search Timeout", state_machine.pathfinding.global_position, Color.PURPLE, 3)
		Transitioned.emit(self, "idle")
		return
	
	# If generate path is too long, like for a target
	# on the other side of the wall, generate next point.
	if get_total_path_distance() > 20:
		DebugCanvas.debug_text("Path Too Long", state_machine.pathfinding.global_position, Color.PURPLE, 3)
		Transitioned.emit(self, "idle")
	

func reached_search_point():
	await get_tree().create_timer(wait_at_search_point).timeout
	move_to_next_search_point()
	

func move_to_next_search_point():
	var random_in_range = Utils.random_inside_circle() * search_range
	var next_search_point = last_seen_position + Vector3(random_in_range.x, 0, random_in_range.y)
	
	# Add a cheat vector towards our target to make AI seem smarter
	if search_target != null:
		var cheat_vector = (search_target.global_position - last_seen_position).normalized() * cheat_amount
		next_search_point += cheat_vector
	
	set_target_position(next_search_point)
	

func exit(state_machine):
	state_machine.awareness_agent.on_enemy_seen.disconnect(enemy_seen)
	state_machine.awareness_agent.on_sound_heard.disconnect(sound_heard)
	state_machine.pathfinding.nav.navigation_finished.disconnect(reached_search_point)
	
	state_machine.pathfinding.clear_override_movement_speed()
	state_machine.pathfinding.clear_override_rotation_speed()
	

func enemy_seen(enemy):
	set_in_blackboard("chase_target", enemy)
	Transitioned.emit(self, "chase")
	

func sound_heard(sound_position):
	# Reset state enter time
	enter_time = Time.get_ticks_msec()
	
	# Future search points will generate around this point
	last_seen_position = sound_position
	set_target_position(sound_position)
	
#	DebugCanvas.debug_text("Sound Heard", sound_position, Color.PURPLE, 3)
	
