extends Node3D

@onready var players = get_children()

func _ready():
	for p in players:
		p.finished.connect(reset_position.bind(p))
	

func play(sound, global_position = null):
	for p in players:
		if not p.playing:
			if global_position:
				p.global_position = global_position
			p.stream = sound
			p.play()
			return
	print(get_parent().name + "." + name + ": Not enought stream players!")

func reset_position(player):
	# Reset to local 0,0,0
	player.position = Vector3.ZERO