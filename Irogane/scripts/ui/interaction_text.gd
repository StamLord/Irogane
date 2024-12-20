extends Label

@onready var interaction = PlayerEntity.player_node.get_node("%interaction")

# Called when the node enters the scene tree for the first time.
func _ready():
	interaction.interactive_changed.connect(update_text)


func update_text(new_text):
	text = new_text.to_upper()
