extends Node
class_name GlossaryDB

const GLOSSARY = {
	"irogane" : {
		"color" : "f30000",
		"description" : "A name given to a variaty of colored, legendary metals."
	},
	"war" : {
		"color" : "ffa500",
		"description" : "There is an ongoing war that takes place across the land."
	}
}

static func get_glossary(id):
	if id in GLOSSARY:
		return { "text" : id,
				"data": GLOSSARY[id] }
	return null
