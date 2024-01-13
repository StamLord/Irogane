extends Window

@onready var button_template = %button_template
@onready var quest_list = %quest_list
@onready var quest_info = %quest_info_text

var fake_window = UIWindow.new()
var selected_quest = null

func _ready():
	load_quest_list()
	clear_selected_quest()
	QuestManager.quests_updated.connect(load_quest_list)
	

func _process(_delta):
	if Input.is_action_just_pressed("quests"):
		if visible:
			hide()
			UIManager.remove_window(fake_window)
		else:
			show()
			UIManager.add_window(fake_window)
			
	if Input.is_action_just_pressed("exit"):
		if visible:
			hide()
	

func _on_close_requested():
	hide()
	UIManager.remove_window(fake_window)
	

func load_quest_list():
	for child in quest_list.get_children():
		if child != button_template:
			child.queue_free()
	
	for quest_id in QuestManager.active_quests.keys():
		var quest = QuestManager.active_quests[quest_id]
		var button = button_template.duplicate()
		
		button.text = quest.title
		button.pressed.connect(quest_clicked.bind(quest))
		
		button.visible = true
		
		quest_list.add_child(button)
	
	update_selected_quest()
	

func quest_clicked(quest: QuestResource):
	selected_quest = quest
	update_selected_quest()
	

func update_selected_quest():
	if selected_quest:
		if selected_quest.quest_id not in QuestManager.active_quests.keys():
			clear_selected_quest()
			return 
		
		quest_info.bbcode_text = build_quest_info()
	

func clear_selected_quest():
	selected_quest = null
	quest_info.bbcode_text = "\n"
	

func build_stage_info(quest_info: String, stage: QuestStageResource, current: bool):
	if stage.completed:
		quest_info = str(quest_info, "[s]%s[/s]" % stage.description, "\n\n")
	else:
		quest_info = str(quest_info, stage.description, "\n\n")
	
	if current:
		for req in stage.stage_requirements:
			if stage.completed:
				quest_info = str(quest_info, "[s]%s[/s]" % req.get_req_description(), "\n")
			else:
				quest_info = str(quest_info, req.get_req_description(), "\n")
				
		quest_info = str(quest_info, "\n")
		
		if stage.completed and stage.after_finish_text != "":
			quest_info = str(quest_info, stage.after_finish_text, "\n\n")
	
	return quest_info
	

func build_quest_info():
	var quest_info = ""
	quest_info = str(quest_info, "[center][font_size=28]%s[/font_size][/center]" % selected_quest.title, "\n\n")
	quest_info = str(quest_info, selected_quest.description, "\n\n")
	var current_stage = selected_quest.first_stage
	
	while current_stage != selected_quest.current_stage:
		quest_info = build_stage_info(quest_info, current_stage, false)
		current_stage = current_stage.next_stage
	
	quest_info = build_stage_info(quest_info, current_stage, true)
	
	return quest_info
	
