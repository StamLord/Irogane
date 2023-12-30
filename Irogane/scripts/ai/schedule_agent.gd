extends Node3D
class_name ScheduleAgent

enum task_type {WAIT, ROAM, GUARD, PATROL}

# task = {	"task_type" : enum (task_type),
# 			"location" : [string, string, ...],
#			"extra_data" : dict

# schedule = { "start_time" (string) : task (dict) }
# "start_time" is a string in 24 hours format: 22:30
@export var schedule = {
	"22:00" : {
		"task_type" = task_type.WAIT,
		"location" = ["guard_a"]
	}}

var sorted_task_hours = [] # Helper array to sort dictionary keys

func _ready():
	# Fix int to task_type enum
	for task in schedule.values():
		if task.has("task_type") and typeof(task["task_type"]) == 2:
			var enum_index = task["task_type"]
			task["task_type"] = task_type[task_type.keys()[enum_index]]
	
	initialize_sorted_task_hours()
#	add_task("350", task_type.GUARD, "origin") # False not enough digits
#	add_task("24:00", task_type.GUARD, "origin") # False bigger than 2359
#	add_task("2200", task_type.GUARD, "origin") # False no ":"
#	add_task("-1000", task_type.GUARD, "origin") # False smaller than 0
#	add_task("23:90", task_type.PATROL, "origin") # False 90 mins
#
#	add_task("01:00", task_type.WAIT, "origin") 
#	add_task("23:30", task_type.PATROL, "origin") 
#	add_task("13:45", task_type.PATROL, "origin") 
	

func _process(delta):
	#print(get_current_task())
	pass

func add_task(start_time, task_type : task_type, location, extra_data = null):
	if schedule.has(start_time):
		return false
	
	if not is_valid_time(start_time):
		return false
	
	var task = {"task_type" : task_type,
				"location" : location,
				"extra_data" : extra_data}
	
	schedule[start_time] = task
	sorted_task_hours.append(start_time)
	sorted_task_hours.sort()
	
	return true
	

func initialize_sorted_task_hours():
	sorted_task_hours.clear()
	for hour in schedule.keys():
		sorted_task_hours.append(hour)
	
	sorted_task_hours.sort()
	

func is_valid_time(hh_mm : String): 
	if hh_mm.length() != 5:
		return false
	
	if hh_mm.count(":") != 1:
		return false
	
	var split_numbers = hh_mm.split(":")
	
	if not split_numbers[0].is_valid_int() or not split_numbers[1].is_valid_int():
		return false
	
	# Hour should be between 0 and 23
	var parsed_hours = split_numbers[0].to_int()
	if parsed_hours < 0 or parsed_hours > 23:
		return false
	
	# Minutes should be between 0 and 59
	var parsed_minutes = split_numbers[1].to_int()
	if parsed_minutes < 0 or parsed_minutes > 59:
		return false
	
	return true
	

func get_current_task():
	# No sorted task hours
	if sorted_task_hours.size() == 0:
		return null
	
	# Return the only task we have
	if sorted_task_hours.size() == 1:
		return schedule[sorted_task_hours[0]]
	
	# TODO: Temporarily work with os time until we have DayNightManager
	var current_time = Time.get_time_string_from_system().substr(0, 5)
	var current_total_minutes = get_time_in_minutes(current_time)
	
	# Iterate over sorted keys
	for i in sorted_task_hours.size():
		var task_hour = sorted_task_hours[i]
		var task_hour_in_minutes = get_time_in_minutes(task_hour)
		
		# Look for the first task_hour that is bigger than currrent_time
		# and return the previous task
		if current_total_minutes < task_hour_in_minutes:
			return schedule[sorted_task_hours[i - 1]] 	# Will return last task in array 
														# if smaller than first task_hour
	
	# Return last task if current_time is bigger than all sorted hours
	return schedule[sorted_task_hours[-1]]
	

func get_time_in_minutes(hh_mm : String):
	# hh_mm exmample: "10:30"
	var hours = hh_mm.substr(0, 2) 		# 10:XX
	var minutes = hh_mm.substr(3, 2)	# XX:30
	return hours.to_int() * 60 + minutes.to_int()
	

func load_data(data):
	schedule = data
	

func save_data():
	pass
	
