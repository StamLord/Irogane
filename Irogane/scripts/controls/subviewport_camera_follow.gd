extends Camera3D

var offset = Vector3.ZERO

func _ready():
	offset = global_position
	

func _process(_delta):
	global_position = owner.global_position + offset
