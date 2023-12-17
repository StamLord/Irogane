extends Node

signal on_scene_loaded()

@onready var loading_scene = preload("res://scenes/loading_screen.tscn").instantiate()

var current_scene = null
var loading_scene_name = null

func _ready():
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)
	

func goto_scene(path):
	call_deferred("_deferred_goto_scene", path)
	

func _process(delta):
	if loading_scene_name:
		var scene_load_status = ResourceLoader.load_threaded_get_status(loading_scene_name, [])
	
		if scene_load_status == ResourceLoader.THREAD_LOAD_LOADED:
			var new_scene = ResourceLoader.load_threaded_get(loading_scene_name)
			current_scene = new_scene.instantiate()
			get_tree().root.add_child(current_scene)
			get_tree().root.remove_child(loading_scene)
			get_tree().current_scene = current_scene
			on_scene_loaded.emit(loading_scene_name)
			loading_scene_name = null
	

func _deferred_goto_scene(path):
	current_scene.free()
	get_tree().root.add_child(loading_scene)
	loading_scene_name = path
	ResourceLoader.load_threaded_request(path)
	