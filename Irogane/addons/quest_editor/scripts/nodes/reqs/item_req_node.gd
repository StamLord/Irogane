@tool
class_name ItemReqNode
extends ReqNode

@onready var item_name = %item_name
@onready var amount = %amount


func load_item_req_data(req: ItemRequirementResource, graph: EditorGraph, node_tree: NodeTree):
	item_name.text = req.item_name
	amount.value = req.amount
	
	req_id.text = req.req_id
	req_desc.text = req.description
	optional.button_pressed = req.optional
	
	load_req_next_stage(req.next_stage, graph, node_tree)
	load_req_rewards(req.rewards, graph, node_tree)
	

func get_item_req_resource(graph: EditorGraph, stage_res: QuestStageResource, quest_res: QuestResource):
	var res = ItemRequirementResource.new()
	
	res.item_name = item_name.text
	res.amount = amount.value

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
	
