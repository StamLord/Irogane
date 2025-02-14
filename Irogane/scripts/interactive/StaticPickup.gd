extends Interactive
class_name StaticPickup

@export var item_id : String
@export var amount = 1

func use(interactor):
	if item_id:
		for i in range(amount):
			if interactor.add_item(item_id):
				amount -= 1
			else:
				break
		
		if amount < 1:
			get_parent().queue_free()
	
