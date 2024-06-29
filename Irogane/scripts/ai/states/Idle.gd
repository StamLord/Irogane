extends NpcState
class_name Idle

@export var roam_range = 10.0
@export var roam_idle_duration = 3.0

var markers :
	get:
		if markers == null:
			markers = SceneManager.current_scene.get_node("markers")
		
		return markers
	

var roam_path_active = false
var roam_idle_start = 0.0

var patrol_index = 0
var patrol_target_reached = false
var patrol_target_reached_time = 0

var current_task = null

var task_handler = {
	ScheduleAgent.task_type.WAIT : wait_task, # 0
	ScheduleAgent.task_type.GUARD : guard_task, # 2
	ScheduleAgent.task_type.PATROL : patrol_task # 3
}

func enter(state_machine):
	reset_target_position()
	
	state_machine.awareness_agent.on_enemy_seen.connect(enemy_seen)
	state_machine.awareness_agent.on_sound_heard.connect(sound_heard)
	
	state_machine.pathfinding.set_override_movement_speed(movement_speed)
	state_machine.pathfinding.set_override_rotation_speed(rotation_speed)
	
	set_alert_mode(false)
	

func physics_update(state_machine, _delta):
	if state_machine.schedule_agent == null:
		reset_target_position()
		reset_rotation_target()
	else:
		perform_task()
	

func exit(state_machine):
	state_machine.awareness_agent.on_enemy_seen.disconnect(enemy_seen)
	
	state_machine.pathfinding.clear_override_movement_speed()
	state_machine.pathfinding.clear_override_rotation_speed()
	

func simple_roam(state_machine, delta):
	perform_collisions(state_machine.pathfinding, state_machine.pathfinding.velocity, 10, delta)
	
	if not roam_path_active and Time.get_ticks_msec() - roam_idle_start >= roam_idle_duration * 1000:
		set_target_position(get_new_roam_target())
		roam_path_active = true
		
		await state_machine.pathfinding.nav.navigation_finished
		roam_path_active = false
		roam_idle_start = Time.get_ticks_msec()
	

func get_new_roam_target():
	var random_in_flat_circle = Utils.random_inside_circle() * roam_range
	return Vector3(random_in_flat_circle.x, global_position.y, random_in_flat_circle.y)
	

func perform_task():
	current_task = get_current_task()
	# task = {	"task_type" : enum (task_type),
	# 			"location" : [string, string, ...],
	#			"patrol_wait" : [int, int, ...],
	#			"react_to_sound" : bool,
	#			"react_to_enemy_seen" : bool,
	
	if current_task == null:
		reset_target_position()
		reset_rotation_target()
	else:
		# Perform task
		task_handler[current_task["task_type"]].call(current_task)
	

func enemy_seen(enemy):
	set_in_blackboard("chase_target", enemy)
	Transitioned.emit(self, "chase")
	

func sound_heard(sound_position):
	if current_task != null and current_task.has("react_to_sound") and current_task["react_to_sound"]:
		set_in_blackboard("search_last_seen_position", sound_position)
		Transitioned.emit(self, "search")
	

func wait_task(task):
	var locations = task["location"]
	
	if markers == null:
		return
		
	var target_marker = markers.get_node(locations[0])
	if target_marker != null:
		set_target_position(target_marker.global_position)
		
		var body_position = get_body_position()
		
		# Face target marker's forward
		var face_direction = body_position + target_marker.basis * Vector3.FORWARD
		set_target_rotation(face_direction)
		
		# Animate
		if task.has("extra_data") and task["extra_data"].has("animation"):
			var distance_to_target = target_marker.global_position.distance_to(body_position)
			if distance_to_target < 1.5:
				DebugCanvas.debug_text(task["extra_data"]["animation"], body_position)
	

func guard_task(task):
	var locations = task["location"]
	
	if markers == null:
		return
		
	var target_marker = markers.get_node(locations[0])
	if target_marker != null:
		set_target_position(target_marker.global_position)
		
		# Face target marker's forward
		var face_direction = get_body_position() + target_marker.basis * Vector3.FORWARD
		set_target_rotation(face_direction)
	

func patrol_task(task):
	var locations = task["location"]
	
	if markers == null:
		return
	
	var target_marker = markers.get_node(locations[patrol_index])
	if target_marker != null:
		set_target_position(target_marker.global_position)
		reset_rotation_target()
		
		# If reached patrol point
		var distance_to_patrol_target = target_marker.global_position.distance_to(get_body_position())
		if distance_to_patrol_target < 1.5:
			# Wait at point
			if task.has("patrol_wait"):
				if patrol_target_reached:
					if patrol_index < task["patrol_wait"].size():
						var time_to_wait = task["patrol_wait"][patrol_index]
						if Time.get_ticks_msec() - patrol_target_reached_time < time_to_wait * 1000:
							rotate_to_marker_forward(target_marker)
							return
				else:
					patrol_target_reached = true
					patrol_target_reached_time = Time.get_ticks_msec()
					return
			
			# Set next patrol index
			patrol_target_reached = false
			patrol_index += 1
			patrol_index %= locations.size()
	

func rotate_to_marker_forward(marker):
	var face_direction = get_body_position() + marker.basis * Vector3.FORWARD
	set_target_rotation(face_direction)
	
