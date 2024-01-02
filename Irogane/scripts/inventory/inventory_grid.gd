extends GridContainer

var items = []

var grid = {}
var cell_size = 64
var grid_width = 0
var grid_height = 0

@onready var visual_slots = get_children()

func _ready():
	var s = get_grid_size(self)
	grid_width = s.x
	grid_height = s.y
	
	for x in range(grid_width):
		grid[x] = {}
		for y in range(grid_height):
			grid[x][y] = false
	

func insert_item(item):
	var item_pos = item.global_position + Vector2(cell_size / 2.0, cell_size / 2.0)
	var g_pos = pos_to_grid_coord(item_pos)
	var item_size = get_grid_size(item)
	if is_grid_space_available(g_pos.x, g_pos.y, item_size.x, item_size.y):
		set_grid_space(g_pos.x, g_pos.y, item_size.x, item_size.y, true)
		item.global_position = global_position + Vector2(g_pos.x, g_pos.y) * cell_size
		items.append(item)
		return true
	else:
		return false
	

func remove_item_from_grid(item):
	var item_pos = item.global_position + Vector2(cell_size / 2.0, cell_size / 2.0)
	var g_pos = pos_to_grid_coord(item_pos)
	var item_size = get_grid_size(item)
	set_grid_space(g_pos.x, g_pos.y, item_size.x, item_size.y, false)
	items.erase(item)
	

func grab_item(pos):
	var item = get_item_under_pos(pos)
	if item == null:
		return null
		
	var item_pos = item.global_position + Vector2(cell_size / 2.0, cell_size / 2.0)
	var g_pos = pos_to_grid_coord(item_pos)
	var item_size = get_grid_size(item)
	set_grid_space(g_pos.x, g_pos.y, item_size.x, item_size.y, false)
	
	items.erase(item)
	
	return item
	

func get_item_under_pos(pos):
	for item in items:
		if item.get_global_rect().has_point(pos):
			return item
	return null
	

func set_grid_space(x, y, w, h, state):
	for i in range(x, x + w):
		for j in range(y, y + h):
			grid[i][j] = state
			visual_slots[j * grid_height + i].occupy(state)
	

func is_grid_space_available(x, y, w, h):
	if x < 0 or y < 0:
		return false
	if x + w > grid_width or y + h > grid_height:
		return false
	for i in range(x, x + w):
		for j in range(y, y + h):
			if grid[i][j]:
				return false
	return true
	

func pos_to_grid_coord(pos):
	var local_pos = pos - global_position
	var results = {}
	results.x = int(local_pos.x / cell_size)
	results.y = int(local_pos.y / cell_size)
	return results
	

func get_grid_size(item):
	var results = {}
	var s = item.size
	results.x = clamp(int(s.x / cell_size), 1, 500)
	results.y = clamp(int(s.y / cell_size), 1, 500)
	return results
	

func insert_item_at_first_available(item):
	for y in range(grid_height):
		for x in range(grid_width):
			if grid[x][y] == false:
				item.global_position = global_position + Vector2(x, y) * cell_size
				if insert_item(item):
					return true	
	return false
	

func remove_first_item_with_id(item_id):
	for item in items:
		var curr_item_id = item.get_meta("id")
		if item_id == curr_item_id:
			remove_item_from_grid(item)
			item.queue_free()
			return true

	return false
	

func get_grid_items():
	var items_dict = {}
	
	for item in items:
		var item_id = item.get_meta("id")
		
		if item_id not in items_dict:
			items_dict[item_id] = 0
		
		items_dict[item_id] += 1
	
	return items_dict
	


func print_items():
	for i in items:
		print(i.get_meta("id"))
	
