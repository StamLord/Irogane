extends Carriable
class_name Pickup

@export var item_id : String

func use(interactor):
	if item_id:
		if interactor.add_item(item_id):
			get_parent().queue_free()
