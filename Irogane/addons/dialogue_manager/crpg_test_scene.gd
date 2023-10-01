extends BaseDialogueTestScene

func _ready() -> void:
	DialogueManager.show_example_dialogue_balloon(resource, title)
