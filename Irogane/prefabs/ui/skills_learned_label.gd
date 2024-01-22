extends Label
@export var skill_tree : SkillTree
@export var display_at_zero = false

func _ready():
	if skill_tree != null:
		skill_tree.state_updated.connect(update_label)
	

func update_label():
	if skill_tree == null:
		return
	
	var learned_amount = skill_tree.get_learned_skills().size()
	if not display_at_zero and learned_amount == 0:
		text = ""
	else:
		text = str(learned_amount)
	
