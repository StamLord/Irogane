extends Node
class_name GoapUnitTest

@onready var a_star = $"../AStarGoap"
@onready var goal_planner = $"../GoapGoalPlanner"

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

func _ready():
	var world_state = { 
		"is_hungry" : true,
		"health" : 80,
		"has_pizza" : false
		}
	
	var current_goal = goal_planner.get_goal(world_state, all_goals)
	assert(current_goal == load("res://scripts/ai/goap/goals/AISatisfyHungerGoal.tres"), 
	"GoapGoalPlanner test failed")
	
	var action_plan = a_star.plan(world_state, current_goal.get_requirements(), all_actions)
	
	assert(action_plan.size() == 4)
	assert(action_plan[1].action == load("res://scripts/ai/goap/actions/AIGotoStore.tres"))
	assert(action_plan[2].action == load("res://scripts/ai/goap/actions/AIBuyHummus.tres"))
	assert(action_plan[3].action == load("res://scripts/ai/goap/actions/AIEatHummus.tres"))
	
