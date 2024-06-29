extends Node
class_name GoapUnitTest

@onready var action_planner = $"../GoapActionPlanner"
@onready var goal_planner = $"../GoapGoalPlanner"

@onready var all_goals = [
	preload("res://data/ai_goals/AISatisfyHungerGoal.tres"),
	preload("res://data/ai_goals/AISelfPreserveGoal.tres"),
	]

@onready var all_actions = [
	preload("res://data/ai_actions/AIBakePizza.tres"),  # no reqs                , cost 3
	preload("res://data/ai_actions/AIEatPizza.tres"),   # req pizza              , cost 1
	preload("res://data/ai_actions/AIGotoStore.tres"),  # no reqs                , cost 1
	preload("res://data/ai_actions/AIBuyHummus.tres"),  # needs to be at store   , cost 1
	preload("res://data/ai_actions/AIEatHummus.tres"),  # needs hummus           , cost 1
	preload("res://data/ai_actions/AIEatPie.tres"),     # req pie (no way to get), cost 1
	]

func _ready():
	var world_state = { 
		"is_hungry" : true,
		"health" : 80,
		"has_pizza" : false
		}
	
	print("TEST: GoapGoalPlanner")
	var current_goal = goal_planner.get_goal(world_state, all_goals)
	assert(current_goal == load("res://scripts/ai/goap/goals/AISatisfyHungerGoal.tres"), 
	"GoapGoalPlanner test failed")
	
	var action_plan = action_planner.plan(world_state, current_goal.get_requirements(), all_actions)
	
	print("TEST: GoapActionPlanner 1/4")
	assert(action_plan.size() == 4)
	print("TEST: GoapActionPlanner 2/4")
	assert(action_plan[1].action == load("res://scripts/ai/goap/actions/AIGotoStore.tres"))
	print("TEST: GoapActionPlanner 3/4")
	assert(action_plan[2].action == load("res://scripts/ai/goap/actions/AIBuyHummus.tres"))
	print("TEST: GoapActionPlanner 4/4")
	assert(action_plan[3].action == load("res://scripts/ai/goap/actions/AIEatHummus.tres"))
	
	print("TEST: AStarNode Comparison 1/2")
	assert(AStarNode.new(null, world_state).is_equal_to(AStarNode.new(null, world_state)))
	print("TEST: AStarNode Comparison 2/2")
	assert(AStarNode.new(all_actions[0], world_state).is_equal_to(AStarNode.new(all_actions[0], world_state)))
	
