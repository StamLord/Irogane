extends Node3D

@onready var animation_tree = $AnimationTree
@onready var character_body = %character_body

const DEFAULT_STATE = "move"
const MOVE_SPEED_PARAM = "parameters/move/move_blend/blend_position"

func _process(delta):
	if not animation_tree:
		return
	
	if not character_body:
		return
	
	var anim_speed = character_body.get_normalized_velocity()
	animation_tree.set(MOVE_SPEED_PARAM, anim_speed)
	

func play(animation_clip: String) -> float:
	if not animation_tree:
		print(owner.name, ": No animation tree was found!")
		return 0.0
	
	if not animation_tree.has_animation(animation_clip):
		print(owner.name, ": No animation clip exists that matches name:", animation_clip)
		return 0.0
	
	animation_tree["parameters/playback"].travel(animation_clip)
	
	# Return the animation length
	var anim_player: AnimationPlayer = animation_tree.get_node(animation_tree.anim_player)
	if anim_player:
		var animation: Animation = anim_player.get_animation(animation_clip)
		if animation:
			return animation.length
	
	return 0.0
	

func play_default(): 
	animation_tree["parameters/playback"].start(DEFAULT_STATE)
	
