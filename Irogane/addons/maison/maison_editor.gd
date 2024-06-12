@tool
extends Control

@onready var agents_container = %agents_container
@onready var agent_window = %agent_window
@onready var agent_name = %agent_name
@onready var action_container = %action_container
@onready var goal_container = %goal_container
@onready var action_file_dialogue = %action_file_dialogue
@onready var goal_file_dialogue = %goal_file_dialogue
@onready var rename_button = $agent_window/Panel/rename_button
@onready var confirm_rename_button = $agent_window/Panel/confirm_rename_button
@onready var rename_edit = $agent_window/Panel/rename_edit

const AGENT_ITEM = preload("res://addons/maison/agent_item.tscn")
const AGENTS_PATH = "res://data/ai_agents/"
const ACTIONS_PATH = "res://data/ai_actions/"
const GOALS_PATH = "res://data/ai_goals/"

var agent_file_paths = []
var current_selected = -1
var current_resource = null

func _ready():
	load_agents()
	

func load_agents():
	agent_file_paths = Utils.get_all_files_in_folder(AGENTS_PATH)
	update_agent_buttons()
	select_agent(max(0, min(current_selected, agent_file_paths.size() - 1)))
	

func update_agent_buttons():
	var agent_count = agent_file_paths.size()
	var button_count = agents_container.get_child_count()
	var diff = agent_count - button_count
	
	create_or_remove_items(diff, create_agent_button, remove_agent_button)
	
	# Set buttons to match agents
	for i in range(agents_container.get_child_count()):
		var btn : Button = agents_container.get_child(i)
		btn.text = agent_file_paths[i].split("/")[-1].split(".")[0]
		#Utils.disconnect_all_from_signal(btn, "pressed")
		if not btn.is_connected("pressed", select_agent):
			btn.pressed.connect(select_agent.bind(i))
	

func create_or_remove_items(diff, create_function, remove_function):
	# Create new items
	if diff > 0:
		for i in range(diff):
			create_function.call()
	# Delete excess items
	elif diff < 0:
		for i in range(abs(diff)):
			remove_function.call()
	

func create_agent_button():
	var btn = Button.new()
	agents_container.add_child(btn)
	

func remove_agent_button():
	agents_container.get_child(-1).free()
	

func select_agent(index : int):
	if index >= agent_file_paths.size():
		current_selected = -1
		current_resource = null
	else:
		current_selected = index
		current_resource = load_resource(agent_file_paths[current_selected])
	
	update_agent_window()
	

func update_agent_window():
	if current_resource == null:
		agent_window.visible = false
		return
	
	agent_window.visible = true
	agent_name.text = current_resource.resource_path.split("/")[-1].split(".")[0]
	
	# Prepare action items
	var diff = current_resource.actions.size() - action_container.get_child_count()
	create_or_remove_items(diff, create_item.bind(action_container), remove_item.bind(action_container))
	update_gui_items(action_container, current_resource.actions, remove_action_from_agent)
	
	# Prepare goal items
	diff = current_resource.goals.size() - goal_container.get_child_count()
	create_or_remove_items(diff, create_item.bind(goal_container), remove_item.bind(goal_container))
	update_gui_items(goal_container, current_resource.goals, remove_goal_from_agent)
	

func update_gui_items(container, array, button_callback):
	for i in range(container.get_child_count()):
		var item = container.get_child(i)
		var resource = array[i]
		item.text = Utils.get_resource_file_name(resource)
		
		var btn = item.get_node("button")
		if btn:
			Utils.disconnect_all_from_signal(btn, "pressed")
			btn.pressed.connect(button_callback.bind(resource))
	

func create_item(container):
	var item = AGENT_ITEM.instantiate()
	container.add_child(item)
	

func remove_item(container):
	var last_child = container.get_child(-1)
	container.remove_child(last_child) # Not deleted immedietly so needs to be moved
	last_child.queue_free()
	

func add_action_to_agent(action_path):
	if current_resource == null:
		return
	
	var res = load_resource(action_path)
	if res != null:
		current_resource.actions.append(res)
		save_resource(current_resource, agent_file_paths[current_selected])
		update_agent_window()
	

func remove_action_from_agent(action):
	if current_resource == null:
		return
	
	current_resource.actions.erase(action)
	save_resource(current_resource, agent_file_paths[current_selected])
	update_agent_window()
	

func add_goal_to_agent(goal_path):
	if current_resource == null:
		return
	
	var res = load_resource(goal_path)
	if res != null:
		current_resource.goals.append(res)
		save_resource(current_resource, agent_file_paths[current_selected])
		update_agent_window()
	

func remove_goal_from_agent(goal):
	if current_resource == null:
		return
	
	current_resource.goals.erase(goal)
	save_resource(current_resource, agent_file_paths[current_selected])
	update_agent_window()
	

func new_agent():
	var new = AIagent.new()
	var file_path = AGENTS_PATH.path_join("New AI Agent.res")
	var new_path = save_new_resource(new, file_path)
	load_agents()
	select_agent(agent_file_paths.find(new_path))
	

func save_resource(resource, file_path):
	var error = ResourceSaver.save(resource, file_path)
	

func save_new_resource(resource, file_path):
	var new_path = get_new_file_name(file_path)
	save_resource(resource, new_path)
	return new_path
	

func load_resource(file_path):
	var resource = ResourceLoader.load(file_path)
	return resource
	

func get_new_file_name(path):
	var new_path = path
	var suffix = 1
	
	while FileAccess.file_exists(new_path):
		new_path = path.get_basename() + "_" + str(suffix) + "." + path.get_extension()
		suffix += 1
	
	return new_path
	

func duplicate_agent():
	if current_resource == null:
		return
	
	if current_selected < 0 or current_selected >= agent_file_paths.size():
		return
	
	var new_path = save_new_resource(current_resource.duplicate(), agent_file_paths[current_selected])
	load_agents()
	select_agent(agent_file_paths.find(new_path))
	

func delete_agent():
	if current_selected < 0 or current_selected >= agent_file_paths.size():
		return
	
	var path = agent_file_paths[current_selected]
	var error = DirAccess.remove_absolute(path)
	
	# Make sure resource is deleted from cach
	current_resource.unreference()
	
	load_agents()
	

func _on_new_button_pressed():
	new_agent()
	

func _on_delete_button_pressed():
	delete_agent()
	

func _on_reload_button_pressed():
	load_agents()
	

func _on_duplicate_button_pressed():
	duplicate_agent()
	

func _on_add_action_pressed():
	action_file_dialogue.show()
	

func _on_action_file_dialogue_files_selected(paths):
	for path in paths:
		add_action_to_agent(path)
	

func _on_action_file_dialogue_file_selected(path):
	add_action_to_agent(path)
	

func _on_add_goal_pressed():
	goal_file_dialogue.show()
	

func _on_goal_file_dialogue_file_selected(path):
	add_goal_to_agent(path)
	

func _on_goal_file_dialogue_files_selected(paths):
	for path in paths:
		add_goal_to_agent(path)
	

func _on_rename_button_pressed():
	rename_edit.text = agent_name.text
	rename_edit.visible = true
	confirm_rename_button.visible = true
	agent_name.visible = false
	rename_button.visible = false
	rename_edit.grab_focus()
	rename_edit.select_all()
	


func _on_confirm_rename_button_pressed():
	rename_edit.visible = false
	confirm_rename_button.visible = false
	agent_name.visible = true
	rename_button.visible = true
	
	if current_resource == null:
		return
	
	var current_name = current_resource.resource_path.split("/")[-1].split(".")[0]
	if current_name == rename_edit.text:
		return
	
	var new_path = AGENTS_PATH.path_join(rename_edit.text) + ".res"
	save_new_resource(current_resource, new_path)
	delete_agent()
	
