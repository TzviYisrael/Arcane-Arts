extends Control

# Define the pools of words to generate placeholder text
var nouns: Array[String] = ["knight", "dragon", "forest", "castle", "moon", "star", "adventure", "treasure", "storm"]
var verbs: Array[String] = ["seeks", "fights", "journeys", "discovers", "challenges", "protects", "defends", "questions"]
var adjectives: Array[String] = ["brave", "mysterious", "ancient", "glowing", "forgotten", "fearsome", "legendary", "hidden"]
var adverbs: Array[String] = ["boldly", "mysteriously", "bravely", "fiercely", "quickly", "cautiously", "silently", "relentlessly"]


func set_page_by_number(value: int, text: String) -> void:
	$Background/Number.text =  "- "+str(value) + " -"
	$Background/Text.text = text #generate_placeholder_text(value)

# Function to generate random placeholder text
func generate_placeholder_text(page_seed: int) -> String:
	var random_noun: String = nouns[page_seed % nouns.size()]
	var random_verb: String = verbs[page_seed % verbs.size()]
	var random_adjective: String = adjectives[page_seed % adjectives.size()]
	var random_adverb: String = adverbs[page_seed % adverbs.size()]

	# Combine the randomly selected words into a sentence
	var sentence: String = "The " + random_adjective + " " + random_noun + " " + random_verb + " " + random_adverb + "."
	return sentence
