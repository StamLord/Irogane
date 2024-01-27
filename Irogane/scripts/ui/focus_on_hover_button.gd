class_name UIButton
extends BaseButton

@export var audio_player: AudioPlayer
@export var focus_sound: AudioStream
@export var node_hover_delegates: Array[Node]

signal ui_button_pressed()
signal ui_button_focused()

func _ready():
	mouse_entered.connect(_mouse_entered)
	focus_entered.connect(_focus_entered)
	
	for node in node_hover_delegates:
		node.mouse_entered.connect(delegate_grab_focus)
	

func _mouse_entered():
	grab_focus()
	

func delegate_grab_focus():
	grab_focus()
	

func _focus_entered():
	ui_button_focused.emit()
	
	if audio_player and focus_sound:
		audio_player.play(focus_sound)
	

func _pressed():
	ui_button_pressed.emit()
	
