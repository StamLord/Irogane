extends Resource
class_name AIagent

@export var direct_sight = 20.0 :
	set(value):
		direct_sight = max(value, 0.0)

@export var peripheral_sight = 5.0 :
	set(value):
		peripheral_sight = max(value, 0.0)

@export var hearing = 20.0 :
	set(value):
			hearing = max(value, 0.0)

@export var goals : Array[Resource]
@export var actions : Array[Resource]
