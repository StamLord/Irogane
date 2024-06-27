extends Node
class_name GoapAgent

@onready var all_goals = [
	preload("res://scripts/ai/goap/goals/AISatisfyHungerGoal.tres"),
	preload("res://scripts/ai/goap/goals/AISelfPreserveGoal.tres"),
	]

@onready var all_actions = [
	preload("res://scripts/ai/goap/actions/AIBakePizza.tres"),  # no reqs                , cost 3
	preload("res://scripts/ai/goap/actions/AIEatPizza.tres"),   # req pizza              , cost 1
	preload("res://scripts/ai/goap/actions/AIGotoStore.tres"),  # no reqs                , cost 1
	preload("res://scripts/ai/goap/actions/AIBuyHummus.tres"),  # needs to be at store   , cost 1
	preload("res://scripts/ai/goap/actions/AIEatHummus.tres"),  # needs hummus           , cost 1
	preload("res://scripts/ai/goap/actions/AIEatPie.tres"),     # req pie (no way to get), cost 1
	]

@onready var action_planner = $"../GoapActionPlanner"
@onready var goal_planner = $"../GoapGoalPlanner"
@onready var time_slicer = $"../TimeSlicer"

var goal_calculation_rate = 1 / 5.0
var action_calculation_rate = 1 / 5.0

var last_goal_time = 0
var last_action_time = 0

var world_state = {}
var world_state_changed = true

var current_goal = null
var current_action_plan = null

var prev_goal = null

var use_time_slicing = true

func _process(delta):
	# Simulate world_state changing every frame
	world_state_changed = true
	prev_goal = null
	
	if world_state_changed and Time.get_ticks_msec() - last_goal_time >= goal_calculation_rate * 1000:
		if use_time_slicing:
			time_slicer.add_call(self, goal_planner.get_goal, [world_state, all_goals], set_goal)
		else:
			current_goal = goal_planner.get_goal(world_state, all_goals)
		last_goal_time = Time.get_ticks_msec()
		world_state_changed = false
	
	if current_goal != null and current_goal != prev_goal and Time.get_ticks_msec() - last_action_time >= action_calculation_rate * 1000:
		if use_time_slicing:
			time_slicer.add_call(self, action_planner.plan, [world_state, current_goal.get_requirements(), all_actions], set_action_plan)
		else:
			current_action_plan = action_planner.plan(world_state, current_goal.get_requirements(), all_actions)
		last_action_time = Time.get_ticks_msec()
	
	prev_goal = current_goal
	

func update_world_state(new_state):
	world_state = new_state
	world_state_changed = true
	

func set_action_plan(action_plan):
	current_action_plan = action_plan
	

func set_goal(goal):
	current_goal = goal
	
