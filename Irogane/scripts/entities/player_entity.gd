extends Node

var player_node = null
var player_name
var sex
var appearance 
var cached_attributes

const PLAYER_SCENE_PATH = "res://prefabs/entities/player.tscn"
const NO_PLAYER_SCENES = ["res://prefabs/ui/character_creator.tscn", "res://scenes/main_menu.tscn"]


func _ready():
	SceneManager.on_scene_loaded.connect(on_scene_loaded)
	SceneManager.on_scene_start_load.connect(on_scene_start_load)
	

func on_scene_start_load(scene_name):
	if player_node == null and not scene_name in NO_PLAYER_SCENES:
		var player_scene = ResourceLoader.load(PLAYER_SCENE_PATH)
		player_node = player_scene.instantiate()
		get_tree().root.add_child(player_node)
		
		player_node.get_node("model/Character").load_appearance(appearance)
		player_node.stats.load_data(cached_attributes)
		cached_attributes = null
	
	if player_node != null and scene_name in NO_PLAYER_SCENES:
		player_node.free()
	

func on_scene_loaded(scene_name):
	if player_node != null:
		player_node.global_position = Vector3.ZERO
	

func set_player_node(node):
	player_node = node
	

func load_player_data(player_data):
	player_name = player_data.name
	sex = player_data.sex
	appearance = player_data.appearance
	cached_attributes = player_data.attributes
	

func get_attributes():
	return cached_attributes
	

func get_appearance():
	return appearance
	

func get_sex():
	return sex
	
