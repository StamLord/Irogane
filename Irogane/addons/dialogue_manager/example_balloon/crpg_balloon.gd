extends CanvasLayer


@onready var balloon: Panel = %Balloon
@onready var character_label: RichTextLabel = %CharacterLabel
@onready var responses_menu: CRPGDialogueResponsesMenu = %ResponsesMenu
@onready var dialogue_container = %dialogue_container
@onready var dialogue_label_asset = preload("res://addons/dialogue_manager/dialogue_label.tscn")
@onready var scroll_container = %scroll_container
@onready var scrollbar = scroll_container.get_v_scroll_bar()
var current_dialogue_label

## The dialogue resource
var resource: DialogueResource

## Temporary game states
var temporary_game_states: Array = []

## See if we are waiting for the player
var is_waiting_for_input: bool = false

## See if we are running a long mutation and should hide the balloon
var will_hide_balloon: bool = false

## The current line
var dialogue_line: DialogueLine:
	set(next_dialogue_line):
		is_waiting_for_input = false
		
		# The dialogue has finished so close the balloon
		if not next_dialogue_line:
			queue_free()
			return
		
		dialogue_line = next_dialogue_line
		
		# Create new dialogue label
		current_dialogue_label = create_dialogue_label()
		
		# Add character name
		if dialogue_line.character:
			dialogue_line.text = dialogue_line.character.capitalize() + ": " + dialogue_line.text
		
		# Add new line after each node
		if not dialogue_line.text.is_empty():	# Mutations call this method too 
			dialogue_line.text += "\n "			# so we don't want to create new lines for them
		
		# Set text
		current_dialogue_label.dialogue_line = dialogue_line
		
		responses_menu.hide()
		responses_menu.set_responses(dialogue_line.responses)

		# Show our balloon
		balloon.show()
		will_hide_balloon = false

		current_dialogue_label.show()
		if not dialogue_line.text.is_empty():
			current_dialogue_label.type_out()
			await current_dialogue_label.finished_typing

		# Wait for input
		if dialogue_line.responses.size() > 0:
			balloon.focus_mode = Control.FOCUS_NONE
			responses_menu.show()
		elif dialogue_line.time != null:
			var time = dialogue_line.text.length() * 0.02 if dialogue_line.time == "auto" else dialogue_line.time.to_float()
			await get_tree().create_timer(time).timeout
			next(dialogue_line.next_id)
		else:
			is_waiting_for_input = true
			balloon.focus_mode = Control.FOCUS_ALL
			balloon.grab_focus()
	get:
		return dialogue_line


func _ready() -> void:
	balloon.hide()
	Engine.get_singleton("DialogueManager").mutated.connect(_on_mutated)
	
	# Scroll to botton whenever we add new items to scroll container
	scrollbar.connect("changed", scroll_to_bottom)


func _unhandled_input(_event: InputEvent) -> void:
	# Only the balloon is allowed to handle input while it's showing
	get_viewport().set_input_as_handled()


## Start some dialogue
func start(dialogue_resource: DialogueResource, title: String, extra_game_states: Array = []) -> void:
	temporary_game_states = extra_game_states
	is_waiting_for_input = false
	resource = dialogue_resource
	self.dialogue_line = await resource.get_next_dialogue_line(title, temporary_game_states)
	
	# Set character label to first character
	character_label.text = dialogue_resource.character_names[0].capitalize()


## Go to the next line
func next(next_id: String) -> void:
	self.dialogue_line = await resource.get_next_dialogue_line(next_id, temporary_game_states)


# Create new entry
func create_dialogue_label():
	var new_label = dialogue_label_asset.instantiate()
	dialogue_container.add_child(new_label)
	
	# Move before last (Responses)
	dialogue_container.move_child(new_label, dialogue_container.get_child_count() - 2)
	
	return new_label

func scroll_to_bottom():
	scroll_container.scroll_vertical = scrollbar.max_value

### Signals


func _on_mutated(_mutation: Dictionary) -> void:
	is_waiting_for_input = false
	will_hide_balloon = true
	get_tree().create_timer(0.1).timeout.connect(func():
		if will_hide_balloon:
			will_hide_balloon = false
			balloon.hide()
	)


func _on_balloon_gui_input(event: InputEvent) -> void:
	# If the user clicks on the balloon while it's typing then skip typing
	if current_dialogue_label.is_typing and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		get_viewport().set_input_as_handled()
		current_dialogue_label.skip_typing()
		return
	
	if not is_waiting_for_input: return
	if dialogue_line.responses.size() > 0: return

	# When there are no response options the balloon itself is the clickable thing
	get_viewport().set_input_as_handled()

	if event is InputEventMouseButton and event.is_pressed() and event.button_index == 1:
		next(dialogue_line.next_id)
	elif event.is_action_pressed("ui_accept") and get_viewport().gui_get_focus_owner() == balloon:
		next(dialogue_line.next_id)


func _on_responses_menu_response_selected(response: DialogueResponse) -> void:
	next(response.next_id)
