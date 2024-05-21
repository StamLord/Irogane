extends Area3D
class_name Hurtbox

signal on_hit(attack_info)

func hit(attack_info):
	#print(name + " hit registered: " + str(attack_info))
	on_hit.emit(attack_info)
	

func set_active(active):
	monitorable = active
	
