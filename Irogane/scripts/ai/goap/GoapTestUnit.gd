extends Node
class_name GoapUnitTest

@onready var all_goals = [
	preload("res://data/ai_goals/AISatisfyHungerGoal.tres"),
	preload("res://data/ai_goals/AISelfPreserveGoal.tres"),
	]

@onready var all_actions = [
	preload("res://data/ai_actions/AIBakePizza.tres"),  # no reqs                , cost 3
	preload("res://data/ai_actions/AIEatPizza.tres"),   # req pizza              , cost 1
	#preload("res://data/ai_actions/AIGotoStore.tres"),  # no reqs                , cost 1
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
	var current_goal = GoapGoalPlanner.get_goal(world_state, all_goals)
	assert(current_goal == load("res://data/ai_goals/AISatisfyHungerGoal.tres"), 
	"GoapGoalPlanner test failed")
	
	# Add dynamic goto
	var dynamic_goto = GotoAction.new(Node3D.new(), {"in_store" : true})
	var dynamic_node = AStarNode.new(dynamic_goto)
	
	var actions = all_actions.duplicate()
	actions.append(dynamic_goto)
	
	var action_plan = GoapActionPlanner.plan(world_state, current_goal.get_requirements(), actions)
	print(action_plan)
	print("TEST: GoapActionPlanner 1/4")
	assert(action_plan.size() == 3)
	print("TEST: GoapActionPlanner 2/4")
	assert(action_plan[0].action == dynamic_goto)
	print("TEST: GoapActionPlanner 3/4")
	assert(action_plan[1].action == load("res://data/ai_actions/AIBuyHummus.tres"))
	print("TEST: GoapActionPlanner 4/4")
	assert(action_plan[2].action == load("res://data/ai_actions/AIEatHummus.tres"))
	
	print("TEST: AStarNode Comparison 1/2")
	assert(AStarNode.new(null, world_state).is_equal_to(AStarNode.new(null, world_state)))
	print("TEST: AStarNode Comparison 2/2")
	assert(AStarNode.new(all_actions[0], world_state).is_equal_to(AStarNode.new(all_actions[0], world_state)))
	
