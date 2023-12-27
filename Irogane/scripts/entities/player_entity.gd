extends Node

var player_node = null
var player_name
var sex
var initial_scene_position = null

var inventory = null

var model_node_path = "model/Character"

const PLAYER_SCENE_PATH = "res://prefabs/entities/player.tscn"
const NO_PLAYER_SCENES = ["res://prefabs/ui/character_creator.tscn", "res://scenes/main_menu.tscn"]


func _ready():
	SceneManager.on_scene_loaded.connect(on_scene_loaded)
	SceneManager.on_scene_start_load.connect(on_scene_start_load)
	

func on_scene_start_load(scene_name):
	delete_player_node_if_needed(scene_name)
	

func on_scene_loaded(_scene_name):
	if player_node != null and initial_scene_position != null:
		player_node.global_position = initial_scene_position
		initial_scene_position = null
	

func set_player_node(node):
	player_node = node
	

func set_player_name(new_name):
	player_name = new_name
	

func create_player_node_if_needed():
	if player_node == null:
		var player_scene = ResourceLoader.load(PLAYER_SCENE_PATH)
		player_node = player_scene.instantiate()
		get_tree().root.add_child(player_node)
	

func delete_player_node_if_needed(scene_name):
	if player_node != null and scene_name in NO_PLAYER_SCENES:
		player_node.free()
	

func load_player_data(player_data):
	create_player_node_if_needed()
	
	initial_scene_position = Vector3.ZERO

	player_node.get_node(model_node_path).load_appearance(player_data.appearance)
	player_node.stats.load_data(player_data.stats)
	
	player_name = player_data.name
	sex = player_data.sex
	

func get_sex():
	return sex
	

func set_sex(new_sex):
	sex = new_sex
	

func get_player_name():
	return player_name
	

func set_inventory(_inventory):
	inventory = _inventory
	

func get_inventory():
	return inventory
	
