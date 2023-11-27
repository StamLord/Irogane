extends Node
class_name AttackInfo

var soft_damage = 0
var hard_damage = 0
var force = Vector3.ZERO
var statuses = []

func _init(soft_damage, hard_damage, force = Vector3.ZERO, statuses = []):
	self.soft_damage = soft_damage
	self.hard_damage = hard_damage
	self.force = force
	self.statuses = statuses

func _to_string():
	return "Damage: " + str(soft_damage) + "/" + str(hard_damage) + " Force: " + str(force) + " Statuses: " + str(statuses)

func clone():
	return AttackInfo.new(soft_damage, hard_damage, force, statuses)
