@tool
extends Control

const QUESTS_DIR = "res://assets/quests/"
const QUEST_FILE_NAME = "quest_{s}.tres"
const QUEST_ID = "quest_{s}"

@onready var graph : EditorGraph = %GraphEdit
@onready var node_tree : NodeTree = $add_node_window/node_tree

# Side bar
@onready var quest_list = %quest_list
@onready var button_template = %button_template

# Top bar Buttons
@onready var add_quest_button = %add_quest_button
@onready var save_quest_button = %save_quest_button
@onready var delete_quest_button = %delete_button
@onready var add_node_button = %add_node

# Windows
@onready var delete_dialog = %delete_dialog
@onready var add_node_window = %add_node_window

var quests: Array[QuestResource] = []
var quest_to_file_name = {}
var selected_quest: QuestResource = null
var selected_quest_node: QuestNode = null


func _ready():
	# fetch quests and dispaly list
	get_quest_files()
	create_quest_list()
	clear_selection()
	
	# icons
	add_quest_button.icon = get_theme_icon("ScriptCreate", "EditorIcons")
	save_quest_button.icon = get_theme_icon("Save", "EditorIcons")
	delete_quest_button.icon = get_theme_icon("Remove", "EditorIcons")
	add_node_button.icon = get_theme_icon("ListSelect", "EditorIcons")
	
	# buttons
	save_quest_button.disabled = true
	delete_quest_button.disabled = true
	add_node_button.disabled = true
	

func clear_selection():
	# set selections to null
	selected_quest = null
	selected_quest_node = null
	graph.selected_quest_node = null
	
	# clean graph
	graph.clear_connections()
	for child in graph.get_children():
		child.queue_free()
	
	# turn off buttons
	save_quest_button.disabled = true
	delete_quest_button.disabled = true
	add_node_button.disabled = true
	

func get_quest_files():
	quests = []
	quest_to_file_name = {}
	
	var directory = DirAccess.open(QUESTS_DIR)
	var files = directory.get_files()
	
	# Filter items according to filename convention
	for file in files:
		if file.split("_")[0] != QUEST_FILE_NAME.split("_")[0]:
			continue
		if file.split(".")[1] != QUEST_FILE_NAME.split(".")[1]:
			continue
		var quest = ResourceLoader.load("%s%s" % [QUESTS_DIR, file], "QuestResource", ResourceLoader.CACHE_MODE_IGNORE)
		quests.append(quest)
		quest_to_file_name[quest] = file
	

func create_quest_list():
	for child in quest_list.get_children():
		if child != button_template:
			child.queue_free()
	
	for quest in quests:
		var button = button_template.duplicate()
		
		button.text = "%s : %s" % [quest.quest_id, quest.title]
		button.pressed.connect(quest_clicked.bind(quest))
		
		button.visible = true
		
		quest_list.add_child(button)
	

func get_highest_ques_index():
	var biggest_index = -1
	var directory = DirAccess.open(QUESTS_DIR)
	var files = directory.get_files()
	
	for file in files:
		if file.split("_")[0] != QUEST_FILE_NAME.split("_")[0]:
			continue
		if file.split(".")[1] != QUEST_FILE_NAME.split(".")[1]:
			continue
		
		var index_int = file.split("_")[1].split(".")[0].to_int()
		if index_int > biggest_index:
			biggest_index = index_int
	
	return biggest_index
	

func quest_clicked(quest):
	if quest == selected_quest:
		return
	
	selected_quest = quest
	update_selected_quest()
	

func update_selected_quest():
	# Turn on all buttons
	save_quest_button.disabled = false
	delete_quest_button.disabled = false
	add_node_button.disabled = false
	
	# Clean graph
	graph.clear_connections()
	for child in graph.get_children():
		child.free()
	
	# create quest node in graph
	selected_quest_node = node_tree.create_quest_node()
	graph.selected_quest_node = selected_quest_node
	selected_quest_node.load_quest_data(selected_quest, graph, node_tree)
	
	selected_quest_node.set_position_offset((Vector2(100.0, 100.0) + graph.scroll_offset) / graph.zoom)
	graph.arrange_nodes()
	

func _on_add_quest_button_pressed():
	var index = get_highest_ques_index() + 1
	var suffix = str(index).pad_zeros(3)
	
	var quest = QuestResource.new()
	quest.quest_id = QUEST_ID.format({"s" : suffix})
	quest.title = "New Quest"
	
	var quest_file_name = QUEST_FILE_NAME.format({"s" : suffix})
	ResourceSaver.save(quest, "%s%s" % [QUESTS_DIR, quest_file_name])
	
	get_quest_files()
	create_quest_list()
	selected_quest = quest
	update_selected_quest()
	

func _on_save_quest_button_pressed():
	selected_quest_node.update_quest_resource(graph)
	ResourceSaver.save(selected_quest, "%s%s" % [QUESTS_DIR, quest_to_file_name[selected_quest]])
	clear_selection()
	get_quest_files()
	create_quest_list()

func _on_delete_button_pressed():
	if selected_quest:
		delete_dialog.dialog_text = "Are you sure you want to delete quest '%s'?" % selected_quest.quest_id
		delete_dialog.popup_centered()
	

func delete_selected_quest():
	if selected_quest:
		var directory = DirAccess.open(QUESTS_DIR)
		directory.remove("%s%s" % [QUESTS_DIR, quest_to_file_name[selected_quest]])
		clear_selection()
		get_quest_files()
		create_quest_list()
	

func _on_add_node_pressed():
	add_node_window.position = get_global_mouse_position()
	add_node_window.popup()
	

func _on_window_close_requested():
	add_node_window.hide()
	

func _on_window_focus_exited():
	add_node_window.hide()
	

