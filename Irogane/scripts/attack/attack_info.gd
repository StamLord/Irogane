extends Node
class_name AttackInfo

var soft_damage = 0
var hard_damage = 0
var damage_type = DamageType.BLUNT
var is_heavy = false
var force = Vector3.ZERO
var statuses = []

func _init(_soft_damage, _hard_damage, _damage_type = DamageType.BLUNT, _is_heavy = false, _force : Vector3 = Vector3.ZERO, _statuses : Array = []):
	self.soft_damage = _soft_damage
	self.hard_damage = _hard_damage
	self.damage_type = _damage_type
	self.is_heavy = _is_heavy
	self.force = _force
	self.statuses = _statuses
	

func _to_string():
	return "Damage: " + str(soft_damage) + "/" + str(hard_damage) + " Heavy: " + str(is_heavy) + " Force: " + str(force) + " Statuses: " + str(statuses)
	

func clone():
	return AttackInfo.new(soft_damage, hard_damage, damage_type, is_heavy, force, statuses)
	

func get_translated(basis : Basis):
	var translated = clone()
	translated.force = basis * translated.force
	return translated
	
