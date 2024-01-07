extends CheckButton


func _ready():
	focus_entered.connect(func():
		var focus_color := get_theme_color(&"font_focus_color", &"Button")
		add_theme_color_override(&"font_pressed_color", focus_color)
	)
		
	focus_exited.connect(func():
		remove_theme_color_override(&"font_pressed_color")
	)

