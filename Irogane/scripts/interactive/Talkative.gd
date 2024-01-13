extends Interactive

@export var dialogue : String
@export var initial_dialog : String
@onready var resource = load("res://dialogues/" + dialogue + ".dialogue")

var talking_to

func use(interactor):
	if dialogue == null or resource == null:
		return
	
	talking_to = interactor
	DialogueManager.show_dialogue(resource, initial_dialog)
	

func _process(_delta):
	if talking_to == null:
		return
	
	var dist = talking_to.global_position.distance_to(global_position)
	
	if dist > 5:
		DialogueManager.hide_dialouge()
		talking_to = null
	
