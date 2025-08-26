extends Control

@onready var interaction = PlayerEntity.player_node.get_node("%interaction")
@onready var button_text = $button_text

func _ready():
	interaction.interactive_changed.connect(update_text)
	

func update_text(new_text):
	if new_text == "":
		visible = false
	else:
		visible = true
		var key = get_interact_key()
		if key != "":
			button_text.text = key
	

func get_interact_key():
	var events = InputMap.action_get_events("use")
	for e in events:
		if e is InputEventKey:
			return OS.get_keycode_string(e.physical_keycode)
	
	return ""
	
