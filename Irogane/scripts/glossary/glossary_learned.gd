extends Node

var learned = {}

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

