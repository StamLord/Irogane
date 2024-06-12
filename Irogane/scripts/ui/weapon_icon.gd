extends TextureRect

const textures = [preload("res://assets/textures/icons/compass_icon.png"), preload("res://assets/textures/icons/piton_icon.png")]

func _ready():
	subscribe_to_player(PlayerEntity.player_node)
	PlayerEntity.player_node_created.connect(subscribe_to_player)
	

func subscribe_to_player(player_node):
	var manager = player_node.get_node("head/main_camera/simple_weapon_manager")
	
	if manager:
		manager.on_index_changed.connect(index_changed)
	

func index_changed(index):
	texture = textures[index]
	
