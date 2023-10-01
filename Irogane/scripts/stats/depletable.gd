extends Node
class_name Depletable

@export var max_value_source : Value
@export var value : int
@export var min_value = 0
@export var max_value = 100

@export var auto_replenish_rate = 1
var last_replenish = 0

signal max_value_changed(new_max_value)
signal value_changed(new_value)

func _process(_delta):
	if(max_value_source.get_value() != max_value):
		max_value = max_value_source.get_value()
		max_value_changed.emit(max_value)
	
	if Time.get_ticks_msec() - last_replenish >= auto_replenish_rate * 1000:
		replenish(1)
		last_replenish = Time.get_ticks_msec()

func get_value():
	return value

func deplete(amount):
	value = clamp(value - amount, min_value, max_value)
	value_changed.emit(value)

func replenish(amount):
	value = clamp(value + amount, min_value, max_value)
	value_changed.emit(value)

func try_deplete(amount) -> bool:
	if amount > value:
		return false
	deplete(amount)
	return true
	
