extends Control

@onready var text_before: RichTextLabel = $Background/VBoxContainer/Text_before
@onready var texture_rect: TextureRect = $Background/VBoxContainer/TextureRect
@onready var text_after: RichTextLabel = $Background/VBoxContainer/Text_after

## Define the pools of words to generate placeholder text
var nouns: Array[String] = ["knight", "dragon", "forest", "castle", "moon", "star", "adventure", "treasure", "storm"]
var verbs: Array[String] = ["seeks", "fights", "journeys", "discovers", "challenges", "protects", "defends", "questions"]
var adjectives: Array[String] = ["brave", "mysterious", "ancient", "glowing", "forgotten", "fearsome", "legendary", "hidden"]
var adverbs: Array[String] = ["boldly", "mysteriously", "bravely", "fiercely", "quickly", "cautiously", "silently", "relentlessly"]


func set_page_by_number(value: int, text: Array) -> void:
	text_before.text = ""
	texture_rect.texture = null
	text_after.text = ""
	$Background/Number.text =  "- "+str(value) + " -"
	var before: bool = true
	for line: String in text:
		if line.begins_with("res://"):
			texture_rect.texture = load(line)
		else:
			if before:
				text_before.newline()
				text_before.append_text(line)
			else:
				text_after.newline()
				text_after.append_text(line)
	

## Function to generate random placeholder text
func generate_placeholder_text(page_seed: int) -> String:
	var random_noun: String = nouns[page_seed % nouns.size()]
	var random_verb: String = verbs[page_seed % verbs.size()]
	var random_adjective: String = adjectives[page_seed % adjectives.size()]
	var random_adverb: String = adverbs[page_seed % adverbs.size()]

	# Combine the randomly selected words into a sentence
	var sentence: String = "The " + random_adjective + " " + random_noun + " " + random_verb + " " + random_adverb + "."
	return sentence
