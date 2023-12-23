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
	search_target = get_from_blackboard("search_target")
	last_seen_position = get_from_blackboard("search_last_seen_position")
	last_direction = get_from_blackboard("search_last_direction")
	
	state_machine.awareness_agent.on_enemy_seen.connect(enemy_seen)
	state_machine.awareness_agent.on_sound_heard.connect(sound_heard)
	
	# Move to first point - Extrapolated search position
	var target = last_seen_position + last_direction * extrapolate_movement_range
	set_target_position(target)
	state_machine.pathfinding.nav.navigation_finished.connect(reached_search_point)

func physics_update(state_machine, delta):
	if search_target == null:
		print("%s: Search target is null. This shouldn't happen!", name)
		Transitioned.emit(self, "idle")
		return
	
	# Search timeout
	if Time.get_ticks_msec() - enter_time > search_duration * 1000:
		DebugCanvas.debug_text("Search Timeout", state_machine.pathfinding.global_position, Color.PURPLE, 3)
		Transitioned.emit(self, "idle")
		return
	

func reached_search_point():
	await get_tree().create_timer(wait_at_search_point).timeout
	move_to_next_search_point()
	

func move_to_next_search_point():
	var random_in_range = Utils.random_inside_circle() * search_range
	var cheat_vector = (search_target.global_position - last_seen_position).normalized() * cheat_amount
	var next_search_point = last_seen_position + cheat_vector + Vector3(random_in_range.x, 0, random_in_range.y)
	set_target_position(next_search_point)
	

func exit(state_machine):
	state_machine.awareness_agent.on_enemy_seen.disconnect(enemy_seen)
	state_machine.awareness_agent.on_sound_heard.disconnect(sound_heard)
	state_machine.pathfinding.nav.navigation_finished.disconnect(reached_search_point)
	

func enemy_seen(enemy):
	if enemy == search_target:
		set_in_blackboard("chase_target", search_target)
		Transitioned.emit(self, "chase")
	

func sound_heard(sound_position):
	# Reset state enter time
	enter_time = Time.get_ticks_msec()
	
	# Future search points will generate around this point
	last_seen_position = sound_position
	set_target_position(sound_position)
	
	DebugCanvas.debug_text("Sound Heard", sound_position, Color.PURPLE, 3)
	
