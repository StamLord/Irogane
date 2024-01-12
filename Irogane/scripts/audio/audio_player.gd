extends Node3D
class_name AudioPlayer

@onready var players = get_children()

func _ready():
	for p in players:
		p.finished.connect(reset_position.bind(p))
	

func play(sound, sound_position = null):
	if players:
		for p in players:
			if not p.playing:
				if sound_position and p is Node3D:
					p.global_position = sound_position
				p.stream = sound
				p.play()
				return
	print(get_parent().name + "." + name + ": Not enought stream players!")
	



func reset_position(player):
	# Reset to local 0,0,0
	if player is Node3D:
		player.position = Vector3.ZERO
	
