extends Area3D

@export var teleport_to_scene_path = ""

func _ready():
	body_entered.connect(teleport)
	

func teleport(body):
	if body == PlayerEntity.player_node:
		SceneManager.goto_scene_no_load(teleport_to_scene_path)
	
