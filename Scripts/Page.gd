extends Control

@onready var text_before: RichTextLabel = $Background/VBoxContainer/Text_before
@onready var texture_rect: TextureRect = $Background/VBoxContainer/TextureRect
@onready var text_after: RichTextLabel = $Background/VBoxContainer/Text_after
@onready var spell_container: HBoxContainer = $Background/VBoxContainer/spell_container


func set_page_by_number(value: int, text: String) -> void:
	text_before.text = ""
	texture_rect.texture = null
	empty_spell_container()
	text_after.text = ""
	$Background/Number.text =  "- "+str(value) + " -"
	var before: bool = true
	for line: String in text.split("\\n"):
		if line.begins_with("res://"):
			texture_rect.texture = load(line)
			before = false
		elif line.begins_with("$"):
			for word in line.split(" "):
				spell_container.add_child(add_magic_word(word))
			before = false
		else:
			if before:
				text_before.newline()
				text_before.append_text(line)
			else:
				text_after.newline()
				text_after.append_text(line)
	

func add_magic_word(word: String) -> Button:
	var button := Button.new()
	button.text = word
	button.add_theme_font_size_override("font_size", 50)
	return button

func empty_spell_container() -> void:
	for ch in spell_container.get_children():
		ch.free()
