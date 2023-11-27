extends RigidBody3D

@onready var hurtbox = $hurtbox

# Called when the node enters the scene tree for the first time.
func _ready():
	hurtbox.on_hit.connect(on_hit)

func on_hit(attack_info):
	apply_impulse(attack_info.force)
