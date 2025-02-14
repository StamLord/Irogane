extends Node3D

@onready var loot = %npc_loot
@onready var sack: Node3D = $gold_sack
const POUCH_POSITION = Vector3(-24.4, 22.5, -18.17) # Tested in editor directly on skeleton
const POUCH_ROTATION = Vector3(10.0, 45.0, -3.0)

@export var skeleton_parent: Node3D
@export var skeleton_name = "Skeleton3D"

var skeleton: Skeleton3D

func _ready():
	loot = owner.get_node("npc_loot")
	
	if skeleton_parent != null:
		var found_skeleton = find_skeleton(skeleton_parent)
		
		if found_skeleton != null:
			skeleton = found_skeleton
	
	setup_skeleton()
	

func find_skeleton(node: Node):
	for child in node.get_children():
		if child is Skeleton3D and child.name == skeleton_name:
			return child
		else:
			var result = find_skeleton(child)
			if result != null:
				return result
	
	return null
	

func setup_skeleton():
	if skeleton == null or loot == null:
		return
	
	for item in loot.items:
		if item == "gold_sack":
			sack.visible = true
			attach_to_bone("mixamorigHips", sack)
			var interactive = sack.get_node("interactive_area")
			if interactive != null:
				interactive.amount = loot.items[item]
	

func attach_to_bone(bone_name: String, node_to_attach: Node3D):
	# Ensure the bone exists
	var bone_index = skeleton.find_bone(bone_name)
	if bone_index == -1:
		return
	
	# Create BoneAttachment3D
	var bone_attachment = BoneAttachment3D.new()
	bone_attachment.bone_name = bone_name
	
	var bone_global_position = skeleton.to_global(skeleton.get_bone_pose_position(bone_index))
	var offset = node_to_attach.global_position - bone_global_position
	
	skeleton.add_child(bone_attachment)
	node_to_attach.reparent(bone_attachment)
	node_to_attach.position = POUCH_POSITION
	node_to_attach.rotation = POUCH_ROTATION
	
	# Ensure transforms are updated
	skeleton.force_update_bone_child_transform(bone_index)
	

