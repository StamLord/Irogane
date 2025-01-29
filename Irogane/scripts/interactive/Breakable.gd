extends Area3D
class_name Breakable

@export var fixed_object : Node3D
@export var broken_object : Node3D
@export var breaking_velocity = 4.0

func _ready():
	area_entered.connect(collision)
	

func collision(area: Area3D):
	if area is Breaker:
		if area.get_velocity().length() >= breaking_velocity:
			break_self()
	

func break_self():
	fixed_object.process_mode = Node.PROCESS_MODE_DISABLED
	fixed_object.visible = false
	
	broken_object.process_mode = Node.PROCESS_MODE_INHERIT
	broken_object.visible = true
	

func fix_self():
	broken_object.process_mode = Node.PROCESS_MODE_DISABLED
	broken_object.visible = false
	
	fixed_object.process_mode = Node.PROCESS_MODE_INHERIT
	fixed_object.visible = true
	
