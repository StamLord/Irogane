extends Node

signal on_quest_started(quest_id: String)
signal on_quest_complete(quest_id: String)
signal on_quest_stage_started(stage_id: String, quest_id: String)
signal on_quest_stage_complete(stage_id: String, quest_id: String)
signal on_quest_req_started(req_id: String, stage_id: String, quest_id: String)
signal on_quest_req_updated(req_id: String, stage_id: String, quest_id: String)
signal on_quest_req_complete(req_id: String, stage_id: String, quest_id: String)

signal quests_updated()

const QUESTS_DIR = "res://assets/quests/"
const QUEST_FILE_NAME = "quest_{s}.tres"

var quests_db = {}
var active_quests = {}
var completed_quests = {}

func _ready():
	on_quest_complete.connect(quest_completed)
	
	load_quest_files()
	
	add_start_quest_command()
	add_get_all_quest_ids()
	add_get_all_active_quest_ids()
	add_get_all_completed_quest_ids()
	add_advance_stage_command()
	add_complete_req_command()
	add_reset_quest_command()
	

func load_quest_files():
	quests_db = {}
	active_quests = {}
	completed_quests = {}
	
	var directory = DirAccess.open(QUESTS_DIR)
	var files = directory.get_files()
	
	# Filter items according to filename convention
	for file in files:
		if file.split("_")[0] != QUEST_FILE_NAME.split("_")[0]:
			continue
		if file.split(".")[1] != QUEST_FILE_NAME.split(".")[1]:
			continue
		var quest = ResourceLoader.load("%s%s" % [QUESTS_DIR, file])
		quests_db[quest.quest_id] = quest
	

func save_quests_data():
	var quests_data = {
		"completed_quests": [],
		"active_quests": [],
	}

	for quest_id in completed_quests:
		quests_data.completed_quests.push_back(quest_id)
	
	for quest_id in active_quests:
		var quest = active_quests[quest_id]
		var quest_data = quest.get_quest_data()
		quests_data.active_quests.push_back(quest_data)
	
	return quests_data
	

func load_quests_data(data):
	if not data:
		return
	
	for quest_id in data.completed_quests:
		var quest = quests_db[quest_id]
		completed_quests[quest_id] = quest
		
	for quest_data in data.active_quests:
		var quest = quests_db[quest_data.id]
		active_quests[quest_data.id] = quest
		quest.load_quest_data(quest_data)
	

func start_quest(quest_id: String):
	if quest_id in active_quests:
		return false
	
	if quest_id  in completed_quests: # currently don't allow repeating quests
		return false
	
	if quest_id not in quests_db:
		return false
	
	var quest = quests_db[quest_id]
	
	active_quests[quest_id] = quest
	quest.start()
	return true
	

# Returns true, if quest_id exists, non active and non completed, and reqs are met
# Used to display "start quest triggers"
func can_start_quest(quest_id: String):
	if not is_quest_available(quest_id):
		return false
		
	var quest = quests_db[quest_id]
	
	for preq_quest_id in quest.prereq_quests_ids:
		if not preq_quest_id in completed_quests:
			return false
	
	return true
	

# Returns true, if quest_id exists, active, and stage_id, exists and current, regardless of completion
# Used to display "stage ongoing triggers"
func is_stage_active(quest_id: String, stage_id: String):
	if quest_id not in active_quests:
		return false
		
	var quest = active_quests[quest_id]
	
	if quest.current_stage.stage_id != stage_id:
		return false
	
	return true
	

# Returns true, if quest_id exists, active, and stage_id, exists, current and completed
# Used to display "stage complete, next stage triggers"
func is_stage_complete(quest_id: String, stage_id: String):
	if quest_id not in active_quests:
		return false
		
	var quest = active_quests[quest_id]
	
	if quest.current_stage.stage_id != stage_id:
		return false
	
	return quest.is_current_stage_complete()
	

func get_current_stage_id(quest_id: String):
	if quest_id not in active_quests:
		return false
	
	var quest = active_quests[quest_id]
	
	return quest.current_stage.stage_id
	

func is_current_stage_complete(quest_id: String):
	if quest_id not in active_quests:
		return false
	
	var quest = active_quests[quest_id]
	
	return quest.is_current_stage_complete()
	

func advance_stage(quest_id: String):
	if quest_id not in active_quests:
		return false
	
	var quest = active_quests[quest_id]
	
	return quest.advance_stage()
	

func has_kept_reward_items(quest_id: String):
	if quest_id not in active_quests:
		return false
		
	var quest = active_quests[quest_id]
	
	return quest.has_kept_reward_items()
	

func apply_kept_reward_items_if_possible(quest_id: String):
	if quest_id not in active_quests:
		return false
		
	var quest = active_quests[quest_id]
	
	return quest.apply_kept_reward_items_if_possible()
	

func complete_req(quest_id: String, stage_id: String, req_id: String):
	if quest_id not in active_quests:
		return false
	
	var quest = active_quests[quest_id]
	
	if quest.current_stage.stage_id != stage_id:
		return false
		
	
	for req in quest.current_stage.stage_requirements:
		if req.req_id == req_id and not req.completed:
			req.complete_req()
			return true
	
	return false
	

func is_quest_active(quest_id: String):
	return quest_id in active_quests
	

func is_quest_complete(quest_id: String):
	return quest_id in completed_quests
	

# Returns true if quest_id, exists, not active and not completed
func is_quest_available(quest_id: String):
	if is_quest_active(quest_id):
		return false
	
	if is_quest_complete(quest_id): # currently don't allow repeating quests
		return false
	
	if quest_id not in quests_db:
		return false
	
	return true
	

func quest_completed(quest_id: String):
	if quest_id not in active_quests:
		return false
	
	var quest = active_quests[quest_id]
	
	completed_quests[quest_id] = quest
	active_quests.erase(quest_id)
	quests_updated.emit()
	return true
	

func reset_quest(quest_id: String):
	if quest_id not in completed_quests:
		return false
	
	var quest = completed_quests[quest_id]
	
	active_quests[quest_id] = quest
	completed_quests.erase(quest_id)
	quests_updated.emit()
	return true

func reset_quest_command(args):
	return "Quest reset: %s" % reset_quest(args[0])
	
func advance_stage_command(args: Array):
	return "Stage Advanced: %s" % advance_stage(args[0])
	

func add_advance_stage_command():
	DebugCommandsManager.add_command(
		"advance_quest_stage",
		advance_stage_command, [
			{
				"arg_name" : "quest_id",
				"arg_type" : DebugCommandsManager.ArgumentType.STRING,
				"arg_desc" : "Quest Id"
			}
		], "Advances quest with quest_id to the next stage (completing it if it's the last stage)")
	

func add_reset_quest_command():
	DebugCommandsManager.add_command(
		"reset_quest",
		reset_quest_command, [
			{
				"arg_name" : "quest_id",
				"arg_type" : DebugCommandsManager.ArgumentType.STRING,
				"arg_desc" : "Quest Id"
			}
		], "Resets a completed quest with quest_id to become available again")
	

func start_quest_commad(args: Array):
	return "Quest Started: %s" % start_quest(args[0])
	

func add_start_quest_command():
	DebugCommandsManager.add_command(
		"start_quest",
		start_quest_commad, [
			{
				"arg_name" : "quest_id",
				"arg_type" : DebugCommandsManager.ArgumentType.STRING,
				"arg_desc" : "Quest Id"
			}
		], "Starts quest with quest_id")
	

func get_all_quest_ids(_args: Array):
	var return_string = ""
	
	for quest_id in quests_db.keys():
		return_string = str(return_string, "%s:%s" % [quest_id, quests_db[quest_id].title], "\n\n")
	
	return return_string
	

func add_get_all_quest_ids():
	DebugCommandsManager.add_command("get_all_quests", get_all_quest_ids, [], "Returns all quest ids in quest DB")
	

func get_all_active_quest_ids(_args: Array):
	return ", ".join(active_quests.keys())
	

func add_get_all_active_quest_ids():
	DebugCommandsManager.add_command("get_active_quests", get_all_active_quest_ids, [], "Returns all active quest ids in quest DB")
	

func get_all_completed_quest_ids(_args: Array):
	return ", ".join(completed_quests.keys())
	

func add_get_all_completed_quest_ids():
	DebugCommandsManager.add_command("get_completed_quests", get_all_completed_quest_ids, [], "Returns all completed quest ids in quest DB")
	

func complete_req_command(args: Array):
	return "Req Completed: %s" % complete_req(args[0], args[1], args[2])
	

func add_complete_req_command():
	DebugCommandsManager.add_command("complete_quest_req", complete_req_command, [
			{
				"arg_name" : "quest_id",
				"arg_type" : DebugCommandsManager.ArgumentType.STRING,
				"arg_desc" : "Quest Id"
			},
			{
				"arg_name" : "stage_id",
				"arg_type" : DebugCommandsManager.ArgumentType.STRING,
				"arg_desc" : "Stage Id"
			},
			{
				"arg_name" : "req_id",
				"arg_type" : DebugCommandsManager.ArgumentType.STRING,
				"arg_desc" : "Requirement Id"
			},
		], "Complete a quest requirement from current stage of an active quest")
	
