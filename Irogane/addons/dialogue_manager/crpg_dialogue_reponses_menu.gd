@icon("./assets/responses_menu.svg")

## A VBoxContainer for dialogue responses provided by [b]Dialogue Manager[/b].
class_name CRPGDialogueResponsesMenu extends VBoxContainer


## Emitted when a response is selected.
signal response_selected(response: DialogueResponse)


@onready var items = get_children()
var _responses: Array[DialogueResponse] = []
var focused = 0

func _ready() -> void:
	visibility_changed.connect(func():
		if visible and items.size() > 0:
			items[0].grab_focus()
	)
	
	for item in items:
		item.gui_input.connect(_on_response_gui_input.bind(item))


## Set the list of responses to show.
func set_responses(next_responses: Array[DialogueResponse]) -> void:
	_responses = next_responses

	# Disable all choices
	for item in items:
		item.visible = false

	# Add new items
	if _responses.size() > 0:
		var i = 0
		for response in _responses:
			var item = items[i]
			item.name = "Response%d" % i
			if not response.is_allowed:
				item.name = String(item.name) + "Disallowed"
				item.modulate.a = 0.4
			item.text = str(i + 1) + ". " + response.text
			item.visible = true
			i += 1
		
		items[0].grab_focus()


### Signals


func _on_response_mouse_entered(item: Control) -> void:
	if "Disallowed" in item.name: return

	item.grab_focus()


func _on_response_gui_input(event: InputEvent, item: Control) -> void:
	if "Disallowed" in item.name: return

	get_viewport().set_input_as_handled()

	if event is InputEventMouseButton and event.is_pressed() and event.button_index == 1:
		response_selected.emit(_responses[item.get_index()])
	elif event.is_action_pressed("ui_accept") and item in items:
		response_selected.emit(_responses[item.get_index()])

func _process(delta):
	
	if Input.is_action_just_pressed("alpha1"):
		select(0)
	elif Input.is_action_just_pressed("alpha2"):
		select(1)
	elif Input.is_action_just_pressed("alpha3"):
		select(2)
	elif Input.is_action_just_pressed("alpha4"):
		select(3)
	elif Input.is_action_just_pressed("alpha5"):
		select(4)
	elif Input.is_action_just_pressed("alpha6"):
		select(5)
	
	if Input.is_action_just_pressed("scroll_down") or Input.is_action_just_pressed("ui_down"):
		increment_focus(1)
	elif Input.is_action_just_pressed("scroll_up") or Input.is_action_just_pressed("ui_up"):
		increment_focus(-1)


func select(index):
	if index >= _responses.size() or index < 0:
		return
	response_selected.emit(_responses[index])


func get_selection() -> int:
	var i = 0
	for item in items:
		if item.has_focus:
			return i
		i += 1
	return -1


func increment_focus(increment):
	var count = _responses.size()
	focused += increment
	if focused  < 0:
		focused += count
	
	if count > 0:
		focused %= count
	
	focus(focused)


func focus(index):
	if index >= 0 and index < items.size():
		items[index].grab_focus()
