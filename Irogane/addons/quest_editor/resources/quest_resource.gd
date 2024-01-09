class_name QuestResource
extends Resource

@export var quest_id: String
@export var title: String
@export var description: String
@export var first_stage: QuestStageResource
@export var prereq_quests_ids: Array[String]

var current_stage: QuestStageResource
var completed = false


func start():
	current_stage = first_stage
	current_stage.start()
	QuestManager.on_quest_started.emit(quest_id)
	

func is_current_stage_complete():
	return current_stage.completed
	

# Advances to the next stage, starting it. If there is no next stage, completes the quest
func advance_stage():
	if not current_stage.completed:
		return false # current stage not complete
	
	# Finish stage
	current_stage.finish()
	
	# Apply rewards for completed reqs in current_stage
	if not current_stage.apply_rewards_if_possible():
		return false
	
	# If last stage, complete quest
	if current_stage.next_stage == null:
		complete_quest()
	else:
		# Start next stage
		current_stage = current_stage.next_stage
		current_stage.start()
	
	return true
	

func has_kept_reward_items():
	return current_stage.has_kept_reward_items()
	

func apply_kept_reward_items_if_possible():
	return current_stage.apply_kept_reward_items_if_possible()
	

func can_complete_quest():
	if current_stage.next_stage != null:
		return false # more stages left
	
	if not current_stage.completed:
		return false # current stage not complete
	
	return true
	

func complete_quest():
	completed = true
	QuestManager.on_quest_complete.emit(quest_id)
	

func get_quest_data():
	var quest_data = {
		"id": quest_id,
		"completed": completed,
		"current_stage_data": {
			"id": current_stage.stage_id,
			"completed": current_stage.completed,
			"next_stage_id": current_stage.next_stage.stage_id if current_stage.next_stage else "",
			"reqs": {},
		}
	}
	
	for req in current_stage.stage_requirements:
		var req_data = {
			"id": req.req_id,
			"completed": req.completed,
		}
		quest_data.current_stage_data.reqs[req.req_id] = req_data
	
	return quest_data
	

func load_quest_data(data):
	completed = data.completed
	current_stage = first_stage
	
	while current_stage.stage_id != data.current_stage_data.id:
		if current_stage.next_stage:
			current_stage = current_stage.next_stage
		else:
			print("Error loading quest '%s', bad current stage id '%s'" % [quest_id, data.current_stage_data.id])
			start()
			return
	
	current_stage.start()
	
	var edit_next_stage = false
	
	if current_stage.next_stage:
		if current_stage.next_stage.stage_id != data.current_stage_data.next_stage_id:
			edit_next_stage = true
	
	var reqs_data = data.current_stage_data.reqs
	
	for req in current_stage.stage_requirements:
		var req_data = reqs_data[req.req_id]
		
		if req_data:
			req.completed = req_data.completed
			
			if edit_next_stage and req.next_stage.stage_id == data.current_stage_data.next_stage_id:
				current_stage.next_stage = req.next_stage
	
	current_stage.completed = data.current_stage_data.completed
	
