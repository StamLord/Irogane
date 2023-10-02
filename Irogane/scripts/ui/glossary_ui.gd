extends UIWindow

@onready var keywords_container = $glossary/margin/ScrollContainer/VBoxContainer
@onready var description_text = $description/margin/description_text

func _ready():
	super()
	visibility_changed.connect(update_keywords)

func update_keywords():
	if not visible: return
	
	# Get all keywords
	var keywords = GlossaryLearned.get_keywords()
	
	# Find delta between keywords nad our items
	var diff = keywords.size() - keywords_container.get_child_count()
	var add_items = true
	
	# We have to many items in our container
	if diff < 0:
		add_items = false
		diff = abs(diff)
	
	# Add / Remove items
	for i in range(diff):
		if add_items:
			var label = Button.new()
			keywords_container.add_child(label)
		else:
			keywords_container.get_child(0).queue_free()
	
	# Wait 1 frame for queue_free to kick in
	await get_tree().create_timer(0).timeout
	
	# Update text
	var i = 0
	for child in keywords_container.get_children():
		if child is Button:
			child.text = keywords[i]
			child.pressed.connect(keyword_pressed.bind(child.text))
		i += 1
		
func keyword_pressed(keyword):
	description_text.text = GlossaryLearned.get_description(keyword)
