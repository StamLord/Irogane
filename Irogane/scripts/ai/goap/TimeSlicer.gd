extends Node
class_name TimeSlicer

# key      : value
# callable : { requester1 : [args_array1, callback1], requester2 : [args_array2, callback2]..}
var call_queues = {}
var calls_per_frame = 4

func _process(delta):
	for call in call_queues:
		var to_remove = []
		for i in range(min(calls_per_frame, call_queues[call].size())):
			# Call function with arguments
			#print("CALLING: ", call.get_method())
			var key = call_queues[call].keys()[i]
			var call_data = call_queues[call][key] # [args_array, callback]
			var call_output = call.callv(call_data[0])
			
			# Callback
			if call_data[1] != null:
				call_data[1].call(call_output)
			
			to_remove.append(key)
		
		for key in to_remove:
			call_queues[call].erase(key)
		
	

func add_call(requester, callable : Callable, arguments, callback : Callable):
	if not call_queues.has(callable):
		call_queues[callable] = {}
	
	# Add or override previous call from this requester
	call_queues[callable][requester] = [arguments, callback]
	
