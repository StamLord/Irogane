extends Node
class_name GoapAgent

@export var agent_data : AIagent

@onready var time_slicer = $"../TimeSlicer"
@onready var awareness_agent = %AwarenessAgent

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
var goto_target = null

var use_time_slicing = false

func _ready():
	if awareness_agent != null:
		awareness_agent.on_enemy_seen.connect(enemy_seen)
	

func _process(delta):
	# Simulate world_state changing every frame
	world_state_changed = true
	prev_goal = null
	
	if world_state_changed and Time.get_ticks_msec() - last_goal_time >= goal_calculation_rate * 1000:
		calculate_goal()
		world_state_changed = false
	
	if current_goal != null and current_goal != prev_goal and Time.get_ticks_msec() - last_action_time >= action_calculation_rate * 1000:
		calculate_plan()
	
	prev_goal = current_goal
	
	if state == STATE.GOTO:
		if goto_target == null or not goto_target is Node3D:
			pass
		
		var dist = body.global_position.distance_to(goto_target.global_position)
		# Continously update pathfiding
		if dist > 0.1:
			body.set_target_position(goto_target)
		else:
			complete_action()
		
	elif state == STATE.ANIMATE:
		# Check if animation is done
		pass
	

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
	goto_target = null
	animating_clip = null
	
	start_action()
	

func animate(animation_clip):
	animating_clip = animation_clip
	state = STATE.ANIMATE
	

func goto(target_node):
	goto_target = target_node
	state = STATE.GOTO
	

func update_world_state(key, value):
	world_state[key] = value
	world_state_changed = true
	

func set_action_plan(action_plan):
	current_action_plan = action_plan
	start_action()
	

func set_goal(goal):
	current_goal = goal
	

func get_dynamic_actions():
	var dynamic_actions = []
	
	if awareness_agent != null:
		for agent in awareness_agent.visible_agents:
			var goto = GotoAction.new(agent.global_position, {"near_enemy" : true})
			dynamic_actions.append(goto)
	
	return dynamic_actions
	

func enemy_seen(enemy):
	update_world_state("enemy_visible", true)
	
