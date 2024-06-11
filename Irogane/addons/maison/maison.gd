@tool
extends EditorPlugin

const MAISON_WINDOW = preload("res://addons/maison/maison_dock.tscn")
var main_panel_instance

func _enter_tree():
	main_panel_instance = MAISON_WINDOW.instantiate()
	get_editor_interface().get_editor_main_screen().add_child(main_panel_instance)
	


func _exit_tree():
	if main_panel_instance:
		main_panel_instance.queue_free()
	

func _has_main_screen():
	return true
	

func _make_visible(visible):
	if main_panel_instance:
		main_panel_instance.visible = visible
	

func _get_plugin_name():
	return "mAIson"
	

func _get_plugin_icon():
	return get_editor_interface().get_base_control().get_theme_icon("ScriptCreateDialog", "EditorIcons")
	
