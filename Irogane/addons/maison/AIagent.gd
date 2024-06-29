extends Resource
class_name AIagent

@export var sight = 20.0 :
	set(value):
		sight = max(value, 0.0)

@export var hearing = 20.0 :
	set(value):
			hearing = max(value, 0.0)

@export var goals : Array[Resource]
@export var actions : Array[Resource]
