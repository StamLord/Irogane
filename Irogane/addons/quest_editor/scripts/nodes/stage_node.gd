@tool
class_name StageNode
extends EditorNode

@onready var stage_id = %stage_id
@onready var desc = %quest_desc
@onready var after_finish_text = %after_finish
@onready var mutex = %mutex


func load_stage_data(stage: QuestStageResource, graph: EditorGraph, node_tree: NodeTree):
	stage_id.text = stage.stage_id
	desc.text = stage.description
	after_finish_text.text = stage.after_finish_text
	mutex.button_pressed = stage.mutually_exclusive
	
	for req in stage.stage_requirements:
		if req is QuestRequirementResource:
			if req is ItemRequirementResource:
				var node = node_tree.create_item_req_node()
				node.load_item_req_data(req, graph, node_tree)
				graph.connect_node(node.name, 0, name, 1)
			else:
				var node = node_tree.create_simple_req_node()
				node.load_req_data(req, graph, node_tree)
				graph.connect_node(node.name, 0, name, 1)
	
	if stage.next_stage != null:
		var node = node_tree.create_stage_node()
		node.load_stage_data(stage.next_stage, graph, node_tree)
		graph.connect_node(name, 0, node.name, 0)
	

func get_stage_resource(graph: EditorGraph, quest_res: QuestResource):
	var res = QuestStageResource.new()
	
	res.stage_id = stage_id.text
	res.quest_id = quest_res.quest_id
	res.description = desc.text
	res.after_finish_text = after_finish_text.text
	res.mutually_exclusive = mutex.button_pressed
	
	var connections = graph.get_all_node_connections(name)
	
	for con in connections:
		if con.to == name:
			var node = graph.get_node(NodePath(con.from))
			if node is ReqNode:
				if node is ItemReqNode:
					res.stage_requirements.push_back(node.get_item_req_resource(graph, res, quest_res))
				else:
					res.stage_requirements.push_back(node.get_req_resource(graph, res, quest_res))
		
		if con.from == name:
			var node = graph.get_node(NodePath(con.to))
			
			if node is StageNode:
				res.next_stage = node.get_stage_resource(graph, quest_res)
	
	return res
	

