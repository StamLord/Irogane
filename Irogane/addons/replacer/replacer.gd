@tool
extends EditorPlugin

var popup_window
var button
const POPUP = preload("res://addons/replacer/popup.tscn")

func _enter_tree():
	button = Button.new()
	button.text = "Replace Nodes"
	button.pressed.connect(_on_button_pressed)
	add_control_to_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, button)
	
	popup_window = POPUP.instantiate()
	get_editor_interface().get_base_control().add_child(popup_window)
	popup_window.hide()
	popup_window.close_requested.connect(popup_window.hide)
	var replace_btn = popup_window.get_node("%replace_button")
	if replace_btn:
		replace_btn.pressed.connect(_on_replace_pressed)
		
	var test_btn = popup_window.get_node("%test_button")
	if test_btn:
		test_btn.pressed.connect(_on_test_pressed)
	

func _exit_tree():
	remove_control_from_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, button)
	popup_window.queue_free()
	

func _on_button_pressed():
	popup_window.popup()
	

func _on_replace_pressed():
	var selected_nodes = get_editor_interface().get_selection().get_selected_nodes()
	print("Selected nodes:", selected_nodes)
	
	var path_input = popup_window.get_node('%resource_path')
	if path_input == null:
		return
	
	var path = path_input.text
	if path == "" or not ResourceLoader.exists(path):
		push_error("Invalid resource path!")
		return
	
	var resource = load(path)
	print("Loaded resource: ", resource, resource is PackedScene)
	
	var keep_children = popup_window.get_node('%keep_children').button_pressed
	print("Keeping children: ", keep_children)
	
	for node in selected_nodes:
		var new_node = resource.instantiate()
		var old_transform = node.get_transform()
		node.get_parent().add_child(new_node)
		new_node.transform = old_transform
		new_node.owner = node.owner
		new_node.name = node.name
		
		node.queue_free()
	
	save_scene()
	
	popup_window.hide()
	

func save_scene():
	var current_scene = get_editor_interface().get_edited_scene_root()
	if current_scene:
		get_editor_interface().save_scene()
		print("Scene saved.")
	else:
		push_error("No scene to save.")
	

func force_save_scene():
	var scene = get_tree().current_scene
	if scene:
		var scene_file = scene.resource_path
		if scene_file:
			ResourceSaver.save(scene_file, scene)
			print("Scene saved with updates.")
	

func _on_test_pressed():
	var editor_interface = get_editor_interface()
	var selected_nodes = editor_interface.get_selection().get_selected_nodes()
	for node in selected_nodes:
		print(node, "isPackedScene: ", node is PackedScene)
	
