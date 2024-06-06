extends Node3D

@onready var mirror_mesh = $mirror_mesh
@onready var left_pos = $left_pos
@onready var right_pos = $right_pos

var pos = -1 # left

func _process(delta):
	if not visible:
		return
	
	if not Input.is_action_pressed("attack_primary") and not Input.is_action_pressed("attack_secondary"):
		mirror_mesh.visible = false
		return
	
	mirror_mesh.visible = true
	
	if Input.is_action_just_pressed("attack_primary"):
		pos = -1
	elif Input.is_action_just_pressed("attack_secondary"):
		pos = 1
	
	var target = left_pos if pos == -1 else right_pos
	
	mirror_mesh.position = lerp(mirror_mesh.position, target.position, 6.0 * delta)
	mirror_mesh.rotation = lerp(mirror_mesh.rotation, target.rotation, 6.0 * delta)
	
