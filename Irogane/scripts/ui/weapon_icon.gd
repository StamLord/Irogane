extends Node3D

const textures = [preload("res://assets/textures/icons/compass_icon.png"), preload("res://assets/textures/icons/piton_icon.png")]
var visible_tool = null

func _ready():
	subscribe_to_player(PlayerEntity.player_node)
	PlayerEntity.player_node_created.connect(subscribe_to_player)
	

func subscribe_to_player(player_node):
	var manager = player_node.get_node("head/main_camera/simple_weapon_manager")
	
	if manager:
		manager.on_index_changed.connect(index_changed)
	

func index_changed(index):
	var count = get_child_count()
	if index >= count:
		return
	
	if visible_tool != null:
		visible_tool.visible = false
	
	visible_tool = get_child(index)
	if visible_tool != null:
		visible_tool.visible = true
	
