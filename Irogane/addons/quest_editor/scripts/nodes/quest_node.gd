@tool
class_name QuestNode
extends EditorNode

@onready var quest_id_label = %quest_id
@onready var quest_title_label = %quest_title
@onready var quest_desc_label = %quest_desc

var quest_resource: QuestResource = null

func load_quest_data(quest: QuestResource, graph: EditorGraph, node_tree: NodeTree):
	quest_resource = quest
	
	quest_id_label.text = quest.quest_id
	quest_title_label.text = quest.title
	quest_desc_label.text = quest.description
	
	for prereq in quest.prereq_quests_ids:
		var node : PrereqQuestNode = node_tree.create_prereq_quest_node()
		node.load_prereq_data(prereq)
		graph.connect_node(node.name, 0, name, 0)
		
	if quest.first_stage:
		var node = node_tree.create_stage_node()
		node.load_stage_data(quest.first_stage, graph, node_tree)
		graph.connect_node(name, 0, node.name, 0)
	

func update_quest_resource(graph: EditorGraph):
	quest_resource.quest_id = quest_id_label.text
	quest_resource.title = quest_title_label.text
	quest_resource.description = quest_desc_label.text
	
	quest_resource.prereq_quests_ids.clear()
	
	var connections = graph.get_all_node_connections(name)
	
	for con in connections:
		if con.to == name:
			var node = graph.get_node(NodePath(con.from))
			
			if node is PrereqQuestNode:
				quest_resource.prereq_quests_ids.push_back(node.get_prereq_quest_id())
			
		if con.from == name:
			var node = graph.get_node(NodePath(con.to))
			
			if node is StageNode:
				quest_resource.first_stage = node.get_stage_resource(graph, quest_resource)
	
