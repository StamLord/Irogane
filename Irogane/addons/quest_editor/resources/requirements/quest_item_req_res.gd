class_name ItemRequirementResource
extends QuestRequirementResource

@export var item_name: String
@export var amount: int
var current_amount = 0

func start():
	EventManager.on_item_pickup.connect(inventory_changed)
	EventManager.on_item_drop.connect(inventory_changed)
	inventory_changed(null)
	# check if player already has item

func finish():
	for i in range(amount):
		PlayerEntity.get_inventory().remove_item(item_name)
	
	if EventManager.on_item_pickup.is_connected(inventory_changed):
		EventManager.on_item_pickup.disconnect(inventory_changed)
	
	if EventManager.on_item_drop.is_connected(inventory_changed):
		EventManager.on_item_drop.disconnect(inventory_changed)
	

func inventory_changed(_item_id):
	var inv = PlayerEntity.get_inventory().get_all_items()
	var new_amount
	
	if item_name not in inv:
		new_amount = 0
	else:
		new_amount = clamp(inv[item_name], 0, amount)
	
	if new_amount == current_amount:
		return 
	
	current_amount = new_amount
	
	if current_amount == amount:
		complete_req()
	else:
		regress_req()
	

func get_req_description():
	return "%s %s/%s" % [description, current_amount, amount]
	
