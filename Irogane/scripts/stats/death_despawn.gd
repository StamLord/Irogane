extends Node

@export var stats : Stats
@export var to_despawn : Node

func _ready():
	stats.on_death.connect(despawn)
	

func despawn():
	if to_despawn:
		to_despawn.queue_free()
	
