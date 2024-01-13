extends Node

signal on_item_pickup(item_id)
signal on_item_drop(item_id)

var enemies_slain = {}
var items_picked_up = {}

func enemy_slain(enemy_id):
	if enemy_id not in enemies_slain:
		enemies_slain[enemy_id] = 0
	
	enemies_slain[enemy_id] += 1
	

func item_picked_up(item_id):
	if item_id not in items_picked_up:
		items_picked_up[item_id] = 0
	
	items_picked_up[item_id] += 1
	on_item_pickup.emit(item_id)
	

func item_dropped(item_id):
	on_item_drop.emit(item_id)
