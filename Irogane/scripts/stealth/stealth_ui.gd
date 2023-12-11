extends Control

@onready var stealth_agent = $"../../../player/head/StealthAgent"
@onready var indicators = get_children()
@export var indicator_radius = 120

func _process(delta):
	if stealth_agent == null:
		return
	
	var watcher_count = stealth_agent.watchers.size()
	
	for i in range(indicators.size()):
		indicators[i].visible = i < watcher_count
		
		if not indicators[i].visible:
			continue
		
		var watcher = stealth_agent.watchers.keys()[i]
		var local_w = stealth_agent.to_local(watcher.global_position)
		var dir = Vector2(local_w.x, local_w.z).normalized()
		
		var offset = Vector2(indicators[i].size.x * 0.5, indicators[i].size.y * 0.5)
		indicators[i].position = Vector2(size.x * 0.5, size.y * 0.5) + dir * indicator_radius - offset
		indicators[i].rotation = dir.angle()
		indicators[i].modulate.a = stealth_agent.watchers[watcher]
		
		i += 1
