@tool
class_name PrereqQuestNode
extends EditorNode

@onready var quest_id_options = %quest_id_options


func load_prereq_data(quest_id: String):
	quest_id_options.selected = -1
	
	for i in range(quest_id_options.item_count):
		if quest_id == quest_id_options.get_item_text(i):
			quest_id_options.selected = i
	

func set_options(options: Array):
	for option in options:
		quest_id_options.add_item(option)
	

func get_prereq_quest_id():
	return quest_id_options.get_item_text(quest_id_options.selected)
	
