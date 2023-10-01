extends Node
class_name Modifier

@export var flat_amount : int
@export var multiply_amount : float

func modify(value):
	value += flat_amount
	value = round(value * multiply_amount)
	
	return value
