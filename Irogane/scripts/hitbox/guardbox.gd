extends Area3D
class_name Guardbox

@export var is_perfect = false

signal on_guard(attack_info, hitbox)
signal on_perfect_guard(attack_info, hitbox)

func guard(attack_info, hitbox):
	if is_perfect:
		on_perfect_guard.emit(attack_info, hitbox)
		#print(name + " hit guarded: " + str(attack_info))
	else:
		on_guard.emit(attack_info, hitbox)
		#print(name + " hit perfectly guarded: " + str(attack_info))
	

func set_active(state):
	monitorable = state
	is_perfect = false
	

func set_perfect(duration):
	is_perfect = true
	await get_tree().create_timer(duration).timeout
	is_perfect = false
	
