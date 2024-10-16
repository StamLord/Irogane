extends TextureProgressBar
class_name DepletableBar

@export var bar_name: String
@export var change_max_value: bool = true
@onready var stats = PlayerEntity.player_node.stats

func _ready():
	var depletable = stats.get_node(bar_name)
	
	if depletable == null:
		return
	
	depletable.value_changed.connect(update_value)
	
	if change_max_value:
		depletable.max_value_changed.connect(update_max_value)
	
	value = depletable.get_value()
	
	if change_max_value:
		max_value = depletable.max_value
	

func update_value(new_value):
	value = new_value
	

func update_max_value(new_max_value):
	max_value = new_max_value
	
