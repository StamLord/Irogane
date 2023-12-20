extends Node

signal on_scene_loaded()
signal on_scene_start_load()

@onready var loading_scene = preload("res://prefabs/ui/loading_screen.tscn").instantiate()

var current_scene = null
var loading_scene_name = null

func _ready():
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)
	

func goto_scene_no_load(path):
	call_deferred("_deferred_goto_scene_no_load", path)
	

func goto_scene(path):
	call_deferred("_deferred_goto_scene", path)
	

func _process(_delta):
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
	

func _deferred_goto_scene_no_load(path):
	on_scene_start_load.emit(path)
	current_scene.free()
	var s = ResourceLoader.load(path)
	current_scene = s.instantiate()
	get_tree().root.add_child(current_scene)
	get_tree().current_scene = current_scene
	on_scene_loaded.emit(path)
	

func _deferred_goto_scene(path):
	on_scene_start_load.emit(path)
	get_tree().root.add_child(loading_scene)
	current_scene.free()
	loading_scene_name = path
	var error = ResourceLoader.load_threaded_request(path)
	
	if error != OK:
		print("Error loading scene: ", error)
	
