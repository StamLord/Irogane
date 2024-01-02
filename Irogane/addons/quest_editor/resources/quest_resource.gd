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
	
	# finish stage
	current_stage.finish()
	
	# Apply rewards for completed reqs in current_stage
	for req in current_stage.stage_requirements:
		if req.completed:
			for reward in req.rewards:
				reward.apply_reward()
	
	if current_stage.next_stage == null:
		complete_quest()
		return true
	
	# Start next stage
	current_stage = current_stage.next_stage
	current_stage.start()
	return true
	

func can_complete_quest():
	if current_stage.next_stage != null:
		return false # more stages left
	
	if not current_stage.completed:
		return false # current stage not complete
	
	return true
	

func complete_quest():
	completed = true
	QuestManager.on_quest_complete.emit(quest_id)
	



