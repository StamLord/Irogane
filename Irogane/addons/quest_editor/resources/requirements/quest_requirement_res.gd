class_name QuestRequirementResource
extends Resource

@export var req_id: String
@export var stage_id: String
@export var quest_id: String
@export var description: String
@export var optional: bool
@export var next_stage: QuestStageResource = null  # next stage for mutually exclusive requirments
@export var rewards: Array[QuestRewardResource]

var completed = false

func complete_req():
	completed = true
	QuestManager.on_quest_req_complete.emit(req_id, stage_id, quest_id)
	QuestManager.quests_updated.emit()
	finish()
	

# Runs for each stage when stage starts, use this in inherited classes to connect to signals to trigger requirement completion
func start():
	return
	

# Clean up connected signals
func finish():
	return
	

func get_req_description():
	return description
	
