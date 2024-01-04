@tool
extends EditorPlugin

const QUEST_MANAGER_WINDOW = preload("res://addons/quest_editor/quest_editor_window.tscn")

var editor_window

func _enter_tree():
	editor_window = QUEST_MANAGER_WINDOW.instantiate()
	get_editor_interface().get_editor_main_screen().add_child(editor_window)
	_make_visible(false)
	

func _exit_tree():
	if editor_window:
		editor_window.queue_free()
	

func _has_main_screen():
	return true
	

func _make_visible(visible):
	if editor_window:
		editor_window.visible = visible

func _get_plugin_name():
	return "Quest Editor"
	

func _get_plugin_icon():
	return get_editor_interface().get_base_control().get_theme_icon("ScriptCreateDialog", "EditorIcons")
	
