@tool
extends EditorPlugin

const MAIN_PANEL = preload("building_blocks_dock.tscn")
var main_panel_instance

func _enter_tree():
	main_panel_instance = MAIN_PANEL.instantiate()
	get_editor_interface().get_editor_main_screen().add_child(main_panel_instance)
	_make_visible(false)
	
	add_custom_type("MyButton", "Button", preload("building_blocks_button.gd"), preload("res://icon.svg"))
	

func _exit_tree():
	remove_custom_type("MyButton")
	
	if main_panel_instance:
		main_panel_instance.queue_free()
	

func _has_main_screen():
	return true
	

func _make_visible(visible):
	if main_panel_instance:
		main_panel_instance.visible = visible
	

func _get_plugin_name():
	return "BuildingBlocks"
	

func _get_plugin_icon():
	return get_editor_interface().get_base_control().get_theme_icon("CollisionShape3D", "EditorIcons")
	
