extends PlayerState
class_name Jump

# Variables
@export var jump_velocity = 4.5

var jump_direction = Vector3.ZERO

func Enter(body):
	jump_direction = body.jump_direction
	

func Update(_delta):
	pass
	

func PhysicsUpdate(body, _delta):
	var velocity = jump_direction * jump_velocity
	body.velocity.x += velocity.x
	body.velocity.y = velocity.y # Reset on y axis instead of adding to negate any falling
	body.velocity.z += velocity.z
	body.move_and_slide()
	
	# Air State
	Transitioned.emit(self, "air")
	

func Exit(body):
	body.jump_direction = Vector3.UP # Reset to default
	
