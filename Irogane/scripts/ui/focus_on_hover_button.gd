extends Button

func _ready():
	mouse_entered.connect(_mouse_entered)
	

func _mouse_entered():
	grab_focus()
	
