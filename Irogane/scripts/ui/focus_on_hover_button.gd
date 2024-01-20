extends Button

@export var audio_player: AudioPlayer
@export var focus_sound: AudioStream

func _ready():
	mouse_entered.connect(_mouse_entered)
	focus_entered.connect(_focus_entered)

func _mouse_entered():
	grab_focus()
	

func _focus_entered():
	if audio_player and focus_sound:
		audio_player.play(focus_sound)
	
