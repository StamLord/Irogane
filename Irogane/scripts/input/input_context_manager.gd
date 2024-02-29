extends Node

var current_context = InputContextType.UI
signal context_changed(old_context, new_context)

func switch_context(new_context):
	context_changed.emit(current_context, new_context)
	current_context = new_context
	

func is_current_context(context):
	return current_context == context
	
