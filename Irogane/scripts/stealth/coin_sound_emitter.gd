extends SoundEmitter

@export var coin : Node3D
@export var sound_range = 5

func _ready():
	if coin:
		coin.on_collision.connect(collision)
	

func collision(body):
	emit_sound(global_position, sound_range)
	
