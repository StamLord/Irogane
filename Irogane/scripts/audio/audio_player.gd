extends Node3D
class_name AudioPlayer

@onready var audio_players = get_children()
var currently_playing = []

func _ready():
	for p in audio_players:
		p.finished.connect(reset_position.bind(p))
	

func play_exclusive(sound, sound_position = null, pitch: float = 1):
	if currently_playing.size() > 0:
		return
	
	play(sound, sound_position, pitch)
	

func play(sound, sound_position = null, pitch: float = 1.0, volume = 0.0 ):
	if audio_players == null:
		return
	
	for p in audio_players:
		if not p.playing:
			if sound_position and p is Node3D:
				p.global_position = sound_position
			
			p.stream = sound
			
			if pitch:
				p.pitch_scale = pitch
			
			if volume:
				p.volume_db = volume
			
			p.play()
			
			# Must avoid duplicate entries since we remove only the first occurance later
			if not currently_playing.has(p):
				currently_playing.append(p)
			
			return
	
	print(get_parent().name + "." + name + ": Not enought stream players!")
	

func reset_position(audio_player):
	# Reset to local 0,0,0
	if audio_player is Node3D:
		audio_player.position = Vector3.ZERO
	
	currently_playing.erase(audio_player)
	
