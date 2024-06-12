@tool
extends Label

@export var slider : Slider

func _ready():
	slider.value_changed.connect(update_value)
	

func update_value(value : float):
	text = str(value)
	
