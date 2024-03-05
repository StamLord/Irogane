extends Node

var current_context = InputContextType.UI
signal context_changed(old_context, new_context)

func switch_context(new_context):
	context_changed.emit(current_context, new_context)
	current_context = new_context
	

func is_current_context(context):
	return current_context == context
	

func is_game_context():
	return current_context == InputContextType.GAME
	

func is_ring_menu_context():
	return current_context == InputContextType.RING_MENU
	

func is_ui_context():
	return current_context == InputContextType.UI
	
