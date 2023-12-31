class_name ItemRequirementResource
extends QuestRequirementResource

@export var item_name: String
@export var amount: int
var current_amount = 0

func start():
	EventManager.on_item_pickup.connect(check_item)
	# check if player already has item

func finish():
	if EventManager.on_item_pickup.is_connected(check_item):
		EventManager.on_item_pickup.disconnect(check_item)
	

func check_item(item_id):
	if item_id == item_name:
		current_amount += 1
		if current_amount == amount:
			complete_req()
	

