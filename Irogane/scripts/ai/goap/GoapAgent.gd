extends Node
class_name GoapAgent

@export var agent_data : AIagent

@onready var time_slicer = $"../TimeSlicer"
@onready var awareness_agent = %AwarenessAgent
@onready var schedule_agent = $ScheduleAgent

var markers :
	get:
		if markers == null:
			markers = SceneManager.current_scene.get_node("markers")
		
		return markers
	

@onready var body = $character_body

enum STATE {NONE, GOTO, ANIMATE}
var state = STATE.NONE

var goal_calculation_rate = 1 / 5.0
var action_calculation_rate = 1 / 5.0

var last_goal_time = 0
var last_action_time = 0

var world_state = {}
var world_state_changed = true

var current_goal = null
var current_action_plan = []

var prev_goal = null
var animating_clip = null
var start_animation_debug = 0
var goto_target = null
var goto_target_position = null

var current_patrol_point = 0

var use_time_slicing = false

func _ready():
	if awareness_agent != null:
		awareness_agent.on_sound_heard.connect(sound_heard)
		
func _process(delta):
	update_sensors()
	#print(world_state)
	
	# Simulate world_state changing every frame
	#world_state_changed = true
	#prev_goal = null
	
	if world_state_changed and Time.get_ticks_msec() - last_goal_time >= goal_calculation_rate * 1000:
		calculate_goal()
		world_state_changed = false
	
	if current_action_plan.size() == 0 and current_goal != null and Time.get_ticks_msec() - last_action_time >= action_calculation_rate * 1000:
		calculate_plan()
	
	prev_goal = current_goal
	
	if state == STATE.GOTO:
		var target = null
		
		if goto_target != null:
			target = goto_target.global_position
		elif goto_target_position != null:
			target = goto_target_position
		
		var dist = body.global_position.distance_to(target)
		
		# Continously update pathfiding
		if dist > 2.0:
			body.set_target_position(target)
		else:
			complete_action()
		
	elif state == STATE.ANIMATE:
		# Check if animation is done
		# TODO: Replace with waiting for real animation
		if Time.get_ticks_msec() - start_animation_debug >= 1.0:
			complete_action()
	

func calculate_goal():
	if use_time_slicing:
		time_slicer.add_call(self, GoapGoalPlanner.get_goal, [world_state, agent_data.goals], set_goal)
	else:
		set_goal(GoapGoalPlanner.get_goal(world_state, agent_data.goals))
	last_goal_time = Time.get_ticks_msec()
	

func calculate_plan():
	var actions = agent_data.actions.duplicate()
	actions.append_array(get_dynamic_actions())
	
	if use_time_slicing:
		time_slicer.add_call(self, GoapActionPlanner.plan, [world_state, current_goal.get_requirements(), actions], set_action_plan)
	else:
		set_action_plan(GoapActionPlanner.plan(world_state, current_goal.get_requirements(), actions))
	
	last_action_time = Time.get_ticks_msec()
	

func start_action():
	if current_action_plan.size() < 1:
		return
	
	current_action_plan[0].action.activate_action(self)
	

func cancel_action():
	goto_target = null
	animating_clip = null
	
	calculate_goal()
	

func complete_action():
	current_action_plan.pop_front()
	state = STATE.NONE
	goto_target = null
	animating_clip = null
	
	start_action()
	

func animate(animation_clip):
	animating_clip = animation_clip
	state = STATE.ANIMATE
	#TODO: Remove this. Only for debug:
	start_animation_debug = Time.get_ticks_msec()
	DebugCanvas.debug_text(animation_clip, body.global_position + Vector3.UP * 2.0, Color.RED, 1.0)
	

func goto(target_node):
	goto_target = target_node
	goto_target_position = null
	state = STATE.GOTO
	

func goto_position(target_position : Vector3):
	goto_target = null
	goto_target_position = target_position
	state = STATE.GOTO
	

func update_world_state(key, value):
	world_state[key] = value
	world_state_changed = true
	

func erase_world_state(key):
	world_state.erase(key)
	world_state_changed = true
	

func set_action_plan(action_plan):
	current_action_plan = action_plan
	print(action_plan)
	start_action()
	

func set_goal(goal):
	current_goal = goal
	

func get_dynamic_actions():
	var dynamic_actions = []
	
	if awareness_agent != null:
		for agent in awareness_agent.visible_agents:
			var goto = GotoAction.new(agent, {"near_enemy": true})
			dynamic_actions.append(goto)
	
	# Goto sound to investigate
	if world_state.has("sound_heard_at"):
		var goto_pos = GotoPositionAction.new(world_state["sound_heard_at"], {"near_sound": true})
		dynamic_actions.append(goto_pos)
	
	# Goto patrol point
	
	if current_goal.to_string() == "AIPatrolGoal":
		var patrol_point = get_patrol_point()
		if patrol_point != null:
			var goto = GotoAction.new(patrol_point, {"near_patrol_point" : true})
			dynamic_actions.append(goto)
		
	return dynamic_actions
	

func sound_heard(sound_position):
	update_world_state("sound_heard_at", sound_position)
	

func get_closest_enemy():
	var closest_agent = null
	var closest_dist = INF
	
	for agent in awareness_agent.visible_agents:
		var distance = body.global_position.distance_to(agent.global_position)
		if closest_agent == null or distance < closest_dist:
			closest_agent = agent_data
			closest_dist = distance
		
	return closest_agent
	

func update_sensors():
	var closest_enemy = get_closest_enemy()
	
	if closest_enemy == null:
		erase_world_state("enemy")
	else:
		update_world_state("enemy", closest_enemy)
	

func get_valid_task():
	if schedule_agent == null or markers == null:
		return null
	
	var task = schedule_agent.get_current_task()
	if task == null:
		return null
	
	return task
	

func get_nearest_patrol_point():
	var nearest_patrol_point = null
	var nearest_distance = INF
	var nearest_patrol_index = -1
	
	var task = get_valid_task()
	if task != null:
		var i = 0
		for location in task["location"]:
			var marker = markers.get_node(location)
			var distance = body.global_position.distance_to(marker.global_position)
			if nearest_patrol_point == null or distance < nearest_distance:
				nearest_patrol_point = marker
				nearest_distance = distance
				nearest_patrol_index = i
			
			i += 1
	
	current_patrol_point = nearest_patrol_index
	return nearest_patrol_point
	

func get_patrol_point():
	# At start of patrol, get nearest
	if current_patrol_point == -1:
		return get_nearest_patrol_point()
	
	# Otherwise, get according to current_patrol_point
	var task = get_valid_task()
	if task == null:
		return null
	
	return markers.get_node(task["location"][current_patrol_point])
	

func set_next_patrol_point():
	var task = get_valid_task()
	if task == null:
		return
	
	current_patrol_point += 1
	current_patrol_point %= task["location"].size()
	
