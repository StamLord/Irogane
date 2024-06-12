extends Carriable

@export var key = Key.new()
@export_range(1,5) var uses = 5

func use(interactor):
	if key:
		interactor.add_key(key.tower_id, key.color, uses)
		get_parent().queue_free()
	
