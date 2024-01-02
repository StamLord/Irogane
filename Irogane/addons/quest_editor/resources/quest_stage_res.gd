class_name QuestStageResource
extends Resource

@export var stage_id: String = ""
@export var quest_id: String = ""
@export var description: String = ""
@export var after_finish_text: String = ""
@export var stage_requirements: Array[QuestRequirementResource] = []
@export var next_stage: QuestStageResource = null
@export var mutually_exclusive: bool = false # only one req can be completed

var completed = false

func start():
	QuestManager.on_quest_req_updated.connect(req_updated)
	QuestManager.on_quest_stage_started.emit(stage_id, quest_id)
	
	for req in stage_requirements:
		QuestManager.on_quest_req_started.emit(req.req_id, stage_id, quest_id)
		req.start()
	
	QuestManager.quests_updated.emit()
	

func req_updated(_req_id: String, _stage_id: String, _quest_id: String):
	if _quest_id != quest_id or _stage_id != stage_id:
		return
	
	check_completion()
	

func check_completion():
	for req in stage_requirements:
		if mutually_exclusive and req.completed:
			next_stage = req.next_stage
			complete_stage()
			return
	
	for req in stage_requirements:
		if not req.completed and not req.optional:
			completed = false
			return
	
	complete_stage()
	

func complete_stage():
	completed = true
	QuestManager.on_quest_stage_complete.emit(stage_id, quest_id)
	QuestManager.quests_updated.emit()
	

func finish():
	if QuestManager.on_quest_req_updated.is_connected(req_updated):
		QuestManager.on_quest_req_updated.disconnect(req_updated)
	
	for req in stage_requirements:
		if req.completed:
			req.finish()
	
