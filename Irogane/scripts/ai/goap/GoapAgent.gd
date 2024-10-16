extends Node
class_name GoapAgent

@export var agent_data : AIagent

@onready var time_slicer = $"../TimeSlicer"
@onready var awareness_agent = %AwarenessAgent
@onready var schedule_agent = $ScheduleAgent
@onready var light_detection = $character_body/light_detection
@onready var body = $character_body

const search_range = 10.0

var markers :
	get:
		if markers == null:
			markers = SceneManager.current_scene.get_node("markers")
		
		return markers
	

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
var current_action_index = 0
var current_action = null

var animating_clip = null
var start_animation_debug = 0
var goto_target = null
var goto_target_position = null

var current_patrol_point = 0

var use_time_slicing = false

var debug = false

func _ready():
	if awareness_agent != null:
		awareness_agent.on_enemy_seen.connect(enemy_seen)
		awareness_agent.on_enemy_lost.connect(enemy_lost)
		awareness_agent.on_sound_heard.connect(sound_heard)
	
	update_world_state("self", body)
	

func _process(delta):
	update_sensors()
	
	# Calculate goal when world state changed
	if world_state_changed and Time.get_ticks_msec() - last_goal_time >= goal_calculation_rate * 1000:
		calculate_goal()
		world_state_changed = false
	
	if state == STATE.GOTO:
		var target = null
		
		if goto_target != null:
			target = goto_target.global_position
		elif goto_target_position != null:
			target = goto_target_position
		
		var flat_target = Vector3(target.x, body.global_position.y, target.z)
		var dist = body.global_position.distance_to(flat_target)
		
		# Continously update pathfiding
		if dist > 2.0:
			body.set_target_position(target)
		else:
			complete_action()
		
	elif state == STATE.ANIMATE:
		# Check if animation is done
		# TODO: Replace with waiting for real animation
		if Time.get_ticks_msec() - start_animation_debug >= 2000:
			complete_action()
	

func calculate_goal():
	if agent_data == null:
		return
	
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
	if current_action_index >= current_action_plan.size():
		return
	
	current_action = current_action_plan[current_action_index].action
	current_action.start_action(self)
	

func cancel_action():
	goto_target = null
	animating_clip = null
	
	calculate_goal()
	

func complete_action():
	current_action.finish_action(self)
	current_action_index += 1
	
	state = STATE.NONE
	goto_target = null
	animating_clip = null
	
	if current_action_index >= current_action_plan.size():
		calculate_goal()
	else:
		start_action()
	

func animate(animation_clip):
	animating_clip = animation_clip
	state = STATE.ANIMATE
	cancel_goto()
	
	#TODO: Remove this. Only for debug:
	start_animation_debug = Time.get_ticks_msec()
	DebugCanvas.debug_text(animation_clip, body.global_position + Vector3.UP * 2.0, Color.RED, 1.0)
	

func goto(target_node):
	goto_target = target_node
	goto_target_position = null
	body.set_target_position(target_node.global_position) # Needs to happen once for rotation
	state = STATE.GOTO
	

func goto_position(target_position : Vector3):
	goto_target = null
	goto_target_position = target_position
	body.set_target_position(target_position) # Needs to happen once for rotation
	state = STATE.GOTO
	

func cancel_goto():
	body.reset_target_position()
	

func update_world_state(key, value):
	if world_state.has(key) and world_state[key] == value:
		return
	world_state[key] = value
	world_state_changed = true
	

func erase_world_state(key):
	if world_state.erase(key):
		world_state_changed = true
	

func set_action_plan(action_plan):
	# No need to restart action plan if it's the same as current
	if current_action_plan != null and is_same_action_plan(current_action_plan, action_plan):
		DEBUG("Got the same action plan, will ignore it.")
		return
	
	current_action_plan = action_plan
	current_action_index = 0
	start_action()
	

func set_goal(goal):
	current_goal = goal
	DEBUG("New goal: " + str(goal))
	
	var color_seed = current_goal.to_string().hash()
	var random_color = Utils.random_color(color_seed)
	for state in current_goal.get_states_to_erase():
		erase_world_state(state)
	
	calculate_plan()
	

func get_dynamic_actions():
	var dynamic_actions = []
	
	if awareness_agent != null:
		for agent in awareness_agent.visible_agents:
			var goto = GotoAction.new(agent, {"near_enemy": true})
			dynamic_actions.append(goto)
	
	# Look at and Goto sound to investigate
	if world_state.has("sound_heard_at"):
		var sound_position = world_state["sound_heard_at"]
		var look_at = AILookAtAction.new(sound_position,  {"looked_at_sound": true})
		var goto_pos = GotoPositionAction.new(sound_position, {"near_sound": true}, {"looked_at_sound": true})
		dynamic_actions.append(look_at)
		dynamic_actions.append(goto_pos)
	
	# Goto search
	if current_goal is AISearchEnemyGoal:
		var goto_pos = GotoPositionAction.new(world_state["search_point"], {"near_search_point": true})
		dynamic_actions.append(goto_pos)
	
	# Goto patrol point
	if current_goal is AIPatrolGoal:
		var patrol_point = get_patrol_point()
		if patrol_point != null:
			var goto = GotoAction.new(patrol_point, {"near_patrol_point": true})
			dynamic_actions.append(goto)
	
	# Goto guard
	if current_goal is AICallGuardGoal:
		var guard = get_nearest_guard()
		var guard_body = guard.get_node("character_body")
		if guard_body != null:
			var goto = GotoAction.new(guard_body, {"near_guard": true})
			dynamic_actions.append(goto)
	
	# Goto nearest light switch that is off
	if current_goal is AILightAreaGoal:
		var light_switch = get_neareast_light_switch_off()
		if light_switch != null:
			var goto = GotoAction.new(light_switch, {"near_light": true})
			dynamic_actions.append(goto)
	
	# Goto coin
	if current_goal is AIPickupCoinGoal and world_state.has("nearest_coin"):
		var goto = GotoAction.new(world_state["nearest_coin"], {"near_coin": true})
		dynamic_actions.append(goto)
	
	return dynamic_actions
	

func sound_heard(sound_position):
	update_world_state("sound_heard_at", sound_position)
	DebugCanvas.debug_point(sound_position, Color.PURPLE, 5.0, 5.0)
	

func get_closest_enemy():
	var closest_agent = null
	var closest_dist = INF
	
	for agent in awareness_agent.visible_agents:
		var distance = body.global_position.distance_to(agent.global_position)
		if closest_agent == null or distance < closest_dist:
			closest_agent = agent
			closest_dist = distance
		
	return closest_agent
	

func enemy_seen(enemy):
	update_closest_enemy()
	

func enemy_lost(enemy):
	if enemy != world_state["enemy"]:
		return
	
	# Fake being smarter by cheating and 
	# losing the enemy after some time
	enemy_lost_cheat_delay(enemy)
	

func enemy_lost_cheat_delay(enemy):
	await get_tree().create_timer(2.0)
	
	update_world_state("enemy_last_seen_at", enemy.global_position)
	update_world_state("search_point", enemy.global_position)
	update_closest_enemy()
	

func update_closest_enemy():
	var closest_enemy = get_closest_enemy()
	if closest_enemy == null:
		erase_world_state("enemy")
	else:
		update_world_state("enemy", closest_enemy)
	

func update_sensors():
	# Light
	if light_detection:
		update_world_state("in_dark", light_detection.light_value < 0.5)
	
	var nearest_light_off = get_neareast_light_switch_off()
	if nearest_light_off != null:
		var distance = body.global_position.distance_to(nearest_light_off.global_position)
		update_world_state("distance_light_off", distance)
	else:
		erase_world_state("distance_light_off")
	
	var light_off_in_range = get_light_switches_off().filter(
		func(light): return light.global_position.distance_to(body.global_position) <= 10)
	
	if light_off_in_range.size() > 0:
		update_world_state("light_off_nearby", true)
	else:
		erase_world_state("light_off_nearby")
	
	# Coins
	var nearest_coin = get_nearest_coin()
	if nearest_coin != null:
		update_world_state("nearest_coin", nearest_coin)
		DebugCanvas.debug_point(nearest_coin.global_position, Color.AQUA)
	else:
		erase_world_state("nearest_coin")
	

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
	

func generate_new_search_point():
	if not world_state.has("enemy_last_seen_at"):
		return
	
	var origin = world_state["enemy_last_seen_at"]
	var random_circle = Utils.random_on_circle() * search_range
	world_state["search_point"] = origin + Vector3(random_circle.x, origin.y, random_circle.y)
	

func get_goap_agents():
	# TODO: Get agents more realistically
	var goap_agents = []
	for child in get_parent().get_children():
		if child is GoapAgent:
			goap_agents.append(child)
	
	return goap_agents
	

func get_guard_agents():
	# TODO: Get guards more realistically
	# TODO: Identify guards more cleverly
	var guards = []
	for child in get_parent().get_children():
		if child is GoapAgent and Utils.get_resource_file_name(child.agent_data) == "Guard":
			guards.append(child)
	
	return guards
	

func get_nearest_guard():
	var guards = get_guard_agents()
	return get_nearest(guards)
	

# Updates the world_state of GoapAgents
# in range with key and value
func inform_agents(range, key, value):
	var agents = get_goap_agents()
	agents = agents.filter(func(agent): return agent != self and body.global_position.distance_to(agent.body.global_position) <= range)
	for agent in agents:
		agent.update_world_state(key, value)
	

func get_light_switches():
	var light_switches = []
	for child in get_parent().get_children():
		if child is LightSwitch:
			light_switches.append(child)
	
	return light_switches
	

func get_light_switches_off():
	return get_light_switches().filter(
		func(switch): return not switch.state)
	

func get_light_switches_on():
	return get_light_switches().filter(
		func(switch): return switch.state)
	

func get_nearest_light_switch():
	var light_switches = get_light_switches()
	return get_nearest(light_switches)
	

func get_neareast_light_switch_on():
	var light_switches = get_light_switches_on()
	return get_nearest(light_switches)
	

func get_neareast_light_switch_off():
	var light_switches = get_light_switches_off()
	return get_nearest(light_switches)
	

func get_nearest(array):
	if array.size() == 0:
		return null
	
	array.sort_custom(sort_nearest)
	return array[0]
	

func sort_nearest(a, b) -> bool:
	var origin = body.global_position
	return origin.distance_to(a.global_position) < origin.distance_to(b.global_position)
	

func interact_nearest_light():
	var light_switch = get_nearest_light_switch()
	if light_switch != null:
		light_switch.use(null)
	

func look_at(target):
	body.set_target_rotation(target)
	

func stop_look_at():
	body.reset_target_rotation()
	

func get_nearby_coins():
	# TODO: Get guards more realistically
	# TODO: Identify guards more cleverly
	var coins = []
	for child in get_tree().root.get_children():
		if "CoinPrefab" in child.name:
			coins.append(child)
	
	return coins
	

func get_nearest_coin():
	return get_nearest(get_nearby_coins())
	

func pickup_nearest_coin():
	if not world_state.has("nearest_coin"):
		return
	
	world_state["nearest_coin"].queue_free()
	erase_world_state("nearest_coin")
	

func is_same_action_plan(plan_a, plan_b):
	if plan_a.size() != plan_b.size():
		return false
	
	for i in range(plan_a.size()):
		if not plan_a[i].action.equals(plan_b[i].action):
			return false
	
	return true
	

func DEBUG(message):
	if not debug:
		return
	print(message)
	
