@tool
class_name NodeTree
extends Tree

@onready var graph: GraphEdit = %GraphEdit
@onready var add_node_window = %add_node_window

# Nodes
@onready var prereq_quest = preload("res://addons/quest_editor/nodes/prereq_quest_node.tscn")

@onready var quest_node = preload("res://addons/quest_editor/nodes/quest_node.tscn")

@onready var stage_node = preload("res://addons/quest_editor/nodes/stage_node.tscn")

@onready var simple_req = preload("res://addons/quest_editor/nodes/reqs/simple_req_node.tscn")
@onready var item_req = preload("res://addons/quest_editor/nodes/reqs/item_req_node.tscn")

@onready var item_reward = preload("res://addons/quest_editor/nodes/rewards/item_reward_node.tscn")

func create_new_node(node_scene):
	var new_node = node_scene.instantiate()
	graph.add_child(new_node)
	new_node.owner = graph
	new_node.set_position_offset((graph.get_local_mouse_position() + graph.scroll_offset) / graph.zoom)
	return new_node
	

func create_stage_node():
	return create_new_node(stage_node)
	

func create_simple_req_node():
	return create_new_node(simple_req)
	

func create_item_reward_node():
	return create_new_node(item_reward)
	

func create_prereq_quest_node():
	var prereq_quest_node = create_new_node(prereq_quest)
	
	var options = []
	
	for quest in owner.quests:
		if quest.quest_id != owner.selected_quest.quest_id:
			options.push_back(quest.quest_id)
	
	prereq_quest_node.set_options(options)
	return prereq_quest_node
	

func create_item_req_node():
	return create_new_node(item_req)
	

func create_quest_node():
	return create_new_node(quest_node)
	

func build_node_tree():
	var root = create_item()

	var prereq_quest = create_item(root)
	prereq_quest.set_text(0, "Prerequisite Quest")
	prereq_quest.set_metadata(0, create_prereq_quest_node) 
	
	var stage = create_item(root)
	stage.set_text(0, "Stage")
	stage.set_metadata(0, create_stage_node) 
	
	var reqs = create_item(root)
	reqs.set_text(0, "Requirements")
	reqs.set_selectable(0, false)
	
	var simple_req = create_item(reqs)
	simple_req.set_text(0, "Simple Requirement")
	simple_req.set_metadata(0, create_simple_req_node) 
	
	var item_req = create_item(reqs)
	item_req.set_text(0, "Item Requirement")
	item_req.set_metadata(0, create_item_req_node) 
	
	var rewards = create_item(root)
	rewards.set_text(0, "Rewards")
	rewards.set_selectable(0, false)
	
	var item_reward = create_item(rewards)
	item_reward.set_text(0, "Item Reward")
	item_reward.set_metadata(0, create_item_reward_node) 
	

func _ready():
	build_node_tree()
	

func _on_item_activated():
	if get_selected().get_metadata(0) == null:
		return
		
	var create_function = get_selected().get_metadata(0)
	create_function.call()
	add_node_window.hide()
	
