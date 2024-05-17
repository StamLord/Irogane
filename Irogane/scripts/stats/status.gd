extends Resource
class_name Status

@export var _name : String
@export var description : String
@export var icon : Texture2D
@export var vfx_prefab : PackedScene

@export var duration_in_sec : int
@export var health_per_sec : int
@export var stamina_per_sec : int

@export var cures : Array[String]
@export var prevents : Array[String]

@export var effects : Array[Effect]
