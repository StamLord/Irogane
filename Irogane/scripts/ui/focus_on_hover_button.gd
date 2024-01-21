extends Button

@export var audio_player: AudioPlayer
@export var focus_sound: AudioStream
@export var node_hover_delegates: Array

func _ready():
	mouse_entered.connect(_mouse_entered)
	focus_entered.connect(_focus_entered)
	
	for node_path in node_hover_delegates:
		get_node(node_path).mouse_entered.connect(delegate_grab_focus)
	

func _mouse_entered():
	grab_focus()
	

func delegate_grab_focus():
	grab_focus()
	

func _focus_entered():
	if audio_player and focus_sound:
		audio_player.play(focus_sound)
	
