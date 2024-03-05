extends Area3D
class_name Guardbox

enum guard_type {NORMAL, PERFECT} 
@export var type = guard_type.NORMAL

signal on_guard(attack_info, hitbox)
signal on_perfect_guard(attack_info, hitbox)

func guard(attack_info, hitbox):
	if type == guard_type.NORMAL:
		on_guard.emit(attack_info, hitbox)
		#print(name + " hit guarded: " + str(attack_info))
	else:
		on_perfect_guard.emit(attack_info, hitbox)
		#print(name + " hit perfectly guarded: " + str(attack_info))
	

func set_active(state):
	monitorable = state
	type = guard_type.NORMAL
	

func set_perfect(duration):
	type = guard_type.PERFECT
	await get_tree().create_timer(duration).timeout
	type = guard_type.NORMAL
	
