extends Node


func _ready():
	var goal = AIGoalAbstract.new()
	var astar_manager = AStarManager.new()
	astar_manager.run_astar(goal)
	
