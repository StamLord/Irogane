extends NpcState
class_name Idle

@export var roam_range = 10.0
@export var roam_idle_duration = 3.0

var roam_path_active = false
var roam_idle_start = 0.0

func enter(state_machine):
	reset_target()
	state_machine.awareness_agent.on_enemy_seen.connect(enemy_seen)
	set_alert_mode(false)
	

func physics_update(state_machine, delta):
	if state_machine.schedule_agent == null:
		simple_roam(state_machine, delta)
	else:
		perform_task()
	

func exit(state_machine):
	state_machine.awareness_agent.on_enemy_seen.disconnect(enemy_seen)
	

func simple_roam(state_machine, delta):
	perform_collisions(state_machine.pathfinding, state_machine.pathfinding.velocity, 10, delta)
	
	if not roam_path_active and Time.get_ticks_msec() - roam_idle_start >= roam_idle_duration * 1000:
		set_target(get_new_roam_target())
		roam_path_active = true
		
		await state_machine.pathfinding.nav.navigation_finished
		roam_path_active = false
		roam_idle_start = Time.get_ticks_msec()
	

func get_new_roam_target():
	var random_in_flat_circle = Utils.random_inside_circle() * roam_range
	return Vector3(random_in_flat_circle.x, global_position.y, random_in_flat_circle.y)
	

func perform_task():
	var task = get_current_task()
	# task = {	"task_type" : enum (task_type),
	# 			"location" : string,
	#			"extra_data" : dict
	
	if task == null:
		set_target(global_position)
		return
	
	var markers = SceneManager.current_scene.get_node("markers")
	print(markers)
	
	if task["task_type"] == ScheduleAgent.task_type.GUARD:
		if markers != null:
			var target_marker = markers.get_node(task["location"])
			print(target_marker)
			if target_marker != null:
				set_target(target_marker.global_position + target_marker.basis * Vector3.FORWARD)
				return
		set_target(global_position)
		
	

func enemy_seen(enemy):
	set_in_blackboard("chase_target", enemy)
	Transitioned.emit(self, "chase")
	
