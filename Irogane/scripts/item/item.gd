extends Node
class_name Item

enum ItemType {MELEE, SWORD, STAFF, KANABO, BOW, SHURIKEN, BOMB, GRAPPLING_HOOK}
enum SlotType {HEAD, TORSO, LEGS, WEAPON, NONE}

@export var type : ItemType
@export var slot : SlotType
@export var cost : int
@export var description : String
