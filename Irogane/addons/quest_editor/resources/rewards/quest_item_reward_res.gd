class_name ItemRewardResource
extends QuestRewardResource

@export var item_name: String
@export var amount: int

func apply_reward():
	for i in range(amount):
		UIManager.get_inventory().pickup_item(item_name)
	
