extends Node3D
class_name hands_ik

@export var left_hand : SkeletonIK3D
@export var right_hand : SkeletonIK3D

var target_left : Vector3
var target_right : Vector3

#func _ready():
	#start_ik()

func _process(delta):
	#if target_left:
	left_hand.get_node(left_hand.target_node).global_position = target_left
	#if target_right:
	right_hand.get_node(right_hand.target_node).global_position = target_right

func start_ik():
	left_hand.start()
	right_hand.start()

func stop_ik():
	left_hand.stop()
	right_hand.stop()

func set_targets(left_position, right_position):
	target_left = left_position
	target_right = right_position
