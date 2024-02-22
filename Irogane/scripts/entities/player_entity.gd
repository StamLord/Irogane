extends Node

var player_node = null
var initial_scene_position = null

var inventory = null
var skills = {}

var model_node_path = "model/human_model"

const PLAYER_SCENE_PATH = "res://prefabs/entities/player.tscn"
const NO_PLAYER_SCENES = ["res://prefabs/ui/character_creator.tscn", "res://scenes/main_menu.tscn"]

signal slot_changed(slot_index)

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
	

func create_player_node_if_needed():
	if player_node == null:
		var player_scene = ResourceLoader.load(PLAYER_SCENE_PATH)
		player_node = player_scene.instantiate()
		get_tree().root.add_child(player_node)
	

func delete_player_node_if_needed(scene_name):
	if player_node != null and scene_name in NO_PLAYER_SCENES:
		player_node.free()
		UIManager.delete_ui_node()
	

func load_player_data(player_data):
	create_player_node_if_needed()
	UIManager.create_ui_node_if_needed()
	
	initial_scene_position = Vector3.ZERO
	
	player_node.get_node(model_node_path).load_appearance(player_data["appearance"])
	player_node.stats.load_data(player_data["stats"])
	skills = player_data["skills"]

func set_inventory(_inventory):
	inventory = _inventory
	inventory.quick_slots.slot_changed.connect(on_slot_changed)
	

func get_inventory():
	return inventory
	

func get_quick_slots():
	if inventory == null:
		return null
	
	return inventory.quick_slots
	

func on_slot_changed(slot_index):
	slot_changed.emit(slot_index)
	

func get_player_name():
	return player_node.stats.name
	

func get_learned_skills():
	return skills
	

func get_skills_in_tree(tree_name: String):
	if skills.has(tree_name):
		return skills[tree_name]
	else:
		return []
	

func set_learned_skills(skills_data):
	skills = skills_data
	
