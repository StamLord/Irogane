@tool
class_name ItemReward
extends EditorNode

@onready var item_name = %item_name
@onready var amount = %amount


func load_item_reward_data(item_reward: ItemRewardResource):
	item_name.text = item_reward.item_name
	amount.value = item_reward.amount
	

func get_item_reward_resource():
	var res = ItemRewardResource.new()
	
	res.item_name = item_name.text
	res.amount = amount.value
	
	return res
	
