@tool
class_name ReqNode
extends EditorNode

@onready var req_id = %req_id
@onready var req_desc = %req_desc
@onready var optional = %optional


func load_req_data(req: QuestRequirementResource, graph: EditorGraph, node_tree: NodeTree):
	req_id.text = req.req_id
	req_desc.text = req.description
	optional.button_pressed = req.optional
	
	load_req_next_stage(req.next_stage, graph, node_tree)
	load_req_rewards(req.rewards, graph, node_tree)
	

func load_req_next_stage(stage: QuestStageResource, graph: EditorGraph, node_tree: NodeTree):
	if stage == null:
		return 
	
	var node = node_tree.create_stage_node()
	node.load_stage_data(stage, graph, node_tree)
	graph.connect_node(name, 0, node.name, 0)
	

func load_req_rewards(rewards: Array[QuestRewardResource], graph: EditorGraph, node_tree: NodeTree):
	for reward in rewards:
		if reward is ItemRewardResource:
			var node = node_tree.create_item_reward_node()
			node.load_item_reward_data(reward)
			graph.connect_node(node.name, 0, name, 0)
	

func get_req_resource(graph: EditorGraph, stage_res: QuestStageResource, quest_res: QuestResource):
	var res = QuestRequirementResource.new()
	
	res.req_id = req_id.text
	res.stage_id = stage_res.stage_id
	res.quest_id = quest_res.quest_id
	res.description = req_desc.text
	res.optional = optional.button_pressed
	
	var rewards = get_req_rewards(graph, quest_res)
	
	for reward in rewards:
		res.rewards.push_back(reward)
		
	res.next_stage = get_req_next_stage(graph, quest_res)
	
	return res
	

func get_req_rewards(graph: EditorGraph, quest_res: QuestResource):
	var rewards = []
	var connections = graph.get_all_node_connections(name)
	
	for con in connections:
		if con.to == name:
			var node = graph.get_node(NodePath(con.from))
			
			if node is ItemReward:
				rewards.push_back(node.get_item_reward_resource())
	
	return rewards
	

func get_req_next_stage(graph: EditorGraph, quest_res: QuestResource):
	var connections = graph.get_all_node_connections(name)
	
	for con in connections:
		if con.from == name:
			if con.from_port == 1:
				var node = graph.get_node(NodePath(con.to))
				
				if node is StageNode:
					return node.get_stage_resource(graph, quest_res)
	
	return null
	
