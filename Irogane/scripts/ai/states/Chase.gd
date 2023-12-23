extends NpcState
class_name Chase

@export var chase_range = 20.0
@export var cheat_duration_after_target_lost = 3.0

var chase_target = null
var chase_start_position = Vector3.ZERO

# Track direction of chase target
#var chase_target_directions = []
var chase_target_directions_smooth = 0.2
var chase_target_last_direction = Vector3.ZERO
var max_chase_target_directions = 1
var last_target_position = Vector3.ZERO

# Target seeing
var lost_target = false
var lost_target_time = 0.0

func enter(state_machine):
	lost_target = false
	chase_start_position = global_position
	chase_target = get_from_blackboard("chase_target")
	last_target_position = chase_target.position
	
	state_machine.awareness_agent.on_enemy_seen.connect(enemy_seen)
	state_machine.awareness_agent.on_enemy_lost.connect(enemy_lost)
	
	set_alert_mode(true)

func physics_update(state_machine, delta):
	if chase_target == null:
		print("%s: Chase target is null. This shouldn't happen!", name)
		Transitioned.emit(self, "idle")
		return
	
	# Target out of chase range
	if global_position.distance_to(chase_target.global_position) > chase_range:
		DebugCanvas.debug_text("Target out of range", state_machine.pathfinding.global_position, Color.PURPLE, 3)
		Transitioned.emit(self, "idle")
		return
	
	# Track chase target's movement direction for an amount of frames
	var current_direction = (chase_target.global_position - last_target_position).normalized()
	chase_target_last_direction = (1 - chase_target_directions_smooth) * chase_target_last_direction + chase_target_directions_smooth * current_direction
	last_target_position = chase_target.global_position
	
	DebugCanvas.debug_line(
		state_machine.pathfinding.global_position, 
		state_machine.pathfinding.global_position + chase_target_last_direction * 2, 
		Color.PURPLE, 7)
	
	# If we lost the target and cheat duration is over
	if lost_target and Time.get_ticks_msec() - lost_target_time > cheat_duration_after_target_lost * 1000:
		# Switch only when done moving to our last target
		if is_navigation_finished():
			switch_to_search_state()
	# Otherwise, chase target
	else:
		set_target_position(chase_target.global_position)
	

func exit(state_machine):
	state_machine.awareness_agent.on_enemy_seen.disconnect(enemy_seen)
	state_machine.awareness_agent.on_enemy_lost.disconnect(enemy_lost)
	

func enemy_lost(enemy):
	if enemy == chase_target:
		lost_target = true
		lost_target_time = Time.get_ticks_msec()
		DebugCanvas.debug_text("Enemy Lost ", last_target_position, Color.PURPLE, 3)
	

func enemy_seen(enemy):
	if enemy == chase_target and lost_target:
		lost_target = false
		DebugCanvas.debug_text("Enemy Regained ", state_machine.pathfinding.global_position, Color.PURPLE, 3)
	

func switch_to_search_state():
	set_in_blackboard("search_target", chase_target)
	set_in_blackboard("search_last_seen_position", chase_target.global_position)
	set_in_blackboard("search_last_direction", chase_target_last_direction)
	Transitioned.emit(self, "search")
	
