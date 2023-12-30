extends Window

@onready var button_template = %button_template
@onready var quest_list = %quest_list

var fake_window = UIWindow.new()


func _ready():
	load_quest_list()
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
	

func quest_clicked(quest):
	pass
	
