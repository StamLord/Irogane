extends Node3D
class_name WeaponBase

@onready var weapon_manager : WeaponManager = %weapon_manager

func signal_attack():
	if weapon_manager: 
		weapon_manager.on_attack.emit()
	

func signal_defend():
	if weapon_manager: 
		weapon_manager.on_defend.emit()
	
