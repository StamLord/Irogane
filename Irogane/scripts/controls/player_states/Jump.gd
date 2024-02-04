extends PlayerState
class_name Jump

# Variables
@export var jump_velocity = 4.5

var direction = Vector3.ZERO

func Enter(_body):
	pass

func Update(_delta):
	pass

func PhysicsUpdate(body, _delta):
	
	body.velocity.y = jump_velocity
	body.move_and_slide()
	
	# Air State
	Transitioned.emit(self, "air")

func Exit(_body):
	pass
