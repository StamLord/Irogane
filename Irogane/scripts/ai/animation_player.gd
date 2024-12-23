extends Node3D

@onready var animation_tree = $AnimationTree
@onready var character_body = %character_body

const MOVE_SPEED_PARAM = "parameters/move/move_blend/blend_position"

func _process(delta):
	if not animation_tree:
		return
	
	if not character_body:
		return
	
	var velocity = Vector3(character_body.velocity.x, 0, character_body.velocity.z)
	var anim_speed = 2.0 if abs(velocity.length()) > 0.1 else 0.0
	animation_tree.set(MOVE_SPEED_PARAM, anim_speed)
	

func play(animation_clip: String):
	if not animation_tree:
		print(owner.name, ": No animation tree was found!")
		return
	
	if not animation_tree.has_animation(animation_clip):
		print(owner.name, ": No animation clip exists that matches name:", animation_clip)
		return
	
	animation_tree.play(animation_clip)
	
