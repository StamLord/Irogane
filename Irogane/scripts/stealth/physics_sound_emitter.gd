extends SoundEmitter

@export var rigidbody : RigidBody3D
@export var velocity_threshold = 5.0
@export var sound_range = 5

func _ready():
	if rigidbody:
		rigidbody.body_entered.connect(collision)
	

func collision(body):
	if rigidbody.linear_velocity.length() > velocity_threshold:
		emit_sound(global_position, sound_range)
	
