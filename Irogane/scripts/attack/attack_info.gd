extends Node
class_name AttackInfo

var soft_damage = 0
var hard_damage = 0
var damage_type = DamageType.BLUNT
var heavy_attack = false
var force = Vector3.ZERO
var statuses = []

func _init(soft_damage, hard_damage, damage_type = DamageType.BLUNT, heavy_attack = false, force : Vector3 = Vector3.ZERO, statuses : Array = []):
	self.soft_damage = soft_damage
	self.hard_damage = hard_damage
	self.damage_type = damage_type
	self.heavy_attack = heavy_attack
	self.force = force
	self.statuses = statuses
	

func _to_string():
	return "Damage: " + str(soft_damage) + "/" + str(hard_damage) + " Heavy: " + str(heavy_attack) + " Force: " + str(force) + " Statuses: " + str(statuses)
	

func clone():
	return AttackInfo.new(soft_damage, hard_damage, damage_type, heavy_attack, force, statuses)
	
