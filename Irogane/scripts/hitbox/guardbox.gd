extends Area3D
class_name Guardbox

enum guard_type {NORMAL, PERFECT} 
@export var type = guard_type.NORMAL

signal on_guard(attack_info)

func guard(attack_info):
	print(name + " hit guarded: " + str(attack_info))
	on_guard.emit(attack_info)
	
