extends Node

var learned = {}

func _ready():
	DebugCommandsManager.add_command(
		"learn_keyword",
		learn_debug,
		 [{
				"arg_name" : "keyword",
				"arg_type" : DebugCommandsManager.ArgumentType.STRING,
				"arg_desc" : "Keyword to learn"
			}],
		"Learn a new keyword"
		)
	

func learn_debug(args : Array):
	learn(args[0])
	

func learn(keyword : String):
	if is_learned(keyword): return
	
	var k = GlossaryDB.get_glossary(keyword)
	if k != null:
		learned[keyword] = k


func is_learned(keyword):
	return learned.has(keyword)


func get_keywords():
	return learned.keys()


func get_description(keyword):
	if is_learned(keyword):
		return learned[keyword].data.description

