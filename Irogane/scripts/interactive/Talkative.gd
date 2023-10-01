extends Interactive

@export var dialogue : String
@onready var resource = load("res://dialogues/" + dialogue + ".dialogue")

var talking_to

func use(interactor):
	if dialogue == null or resource == null:
		return
	
	talking_to = interactor
	DialogueManager.show_dialogue(resource, "farmer_greetings")

func _process(delta):
	if talking_to == null:
		return
	
	var dist = talking_to.global_position.distance_to(global_position)
	if dist > 5:
		#var varray : Array[Dictionary] = [{"type" : "end_dialogue"}]
		#DialogueManager.mutate({"expression" : varray}, [null])
		talking_to = null
