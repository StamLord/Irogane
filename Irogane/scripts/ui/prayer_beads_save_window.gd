extends UIWindow

func _ready():
	if PlayerEntity.player_node != null:
		subscribe_to_player(PlayerEntity.player_node)
	
	PlayerEntity.player_node_created.connect(subscribe_to_player)
	

func subscribe_to_player(player_node):
	var save_tool = player_node.get_node("head/main_camera/simple_weapon_manager/prayer_beads")
	if save_tool != null:
		save_tool.on_prayer_finished.connect(open)
	

func open():
	visible = true
	UIManager.add_window(self)
	get_tree().paused = true
	

func close():
	visible = false
	UIManager.remove_window(self)
	get_tree().paused = false
	
