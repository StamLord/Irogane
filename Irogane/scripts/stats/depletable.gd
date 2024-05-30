extends Node
class_name Depletable

@export var max_value_source : Value
@export var value : int
@export var min_value = 0
@export var max_value = 100

@export var auto_replenish_rate = 1.0
var last_replenish = 0

@export var recovery_after_deplete = 5.0
var last_deplete = 0

var godmode = false

signal max_value_changed(new_max_value)
signal value_changed(new_value)

func _process(_delta):
	if(max_value_source.get_value() != max_value):
		max_value = max_value_source.get_value()
		max_value_changed.emit(max_value)
	
	if Time.get_ticks_msec() - last_deplete >= recovery_after_deplete * 1000 and (
		Time.get_ticks_msec() - last_replenish >= auto_replenish_rate * 1000):
			replenish(1)
			last_replenish = Time.get_ticks_msec()
	

func set_value(_value):
	self.value = clamp(_value, min_value, max_value)
	value_changed.emit(_value)
	

func get_value():
	return value
	

func deplete(amount, is_greedy = true):
	if godmode:
		return true
	
	var is_enough = value >= amount
	if not is_enough and not is_greedy:
		return false
	
	set_value(value - amount)
	last_deplete = Time.get_ticks_msec()
	
	return is_enough
	

func replenish(amount):
	set_value(value + amount)
	

func try_deplete(amount) -> bool:
	if amount > value:
		return false
	deplete(amount)
	return true
	

func set_godmode(state):
	godmode = state
	
	if godmode:
		set_value(max_value)
	

func save_data():
	var data = {
		"value" : value,
		"last_replenish" : last_replenish
	}
	
	return data
	

func load_data(data):
	value = data["value"]
	last_replenish = data["last_replenish"]
	
