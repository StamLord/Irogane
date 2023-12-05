extends UIWindow
@onready var settings = $settings

func open():
	visible = true
	UIManager.add_window(self)
	get_tree().paused = true
	
func close():
	settings.close()
	
	visible = false
	UIManager.remove_window(self)
	get_tree().paused = false


func _on_continue_pressed():
	close()
	

func _on_settings_pressed():
	settings.open()


func _on_quit_pressed():
	get_tree().quit()
