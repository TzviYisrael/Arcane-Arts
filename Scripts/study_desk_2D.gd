extends Node2D

@onready var book_selection_ui: Control = $Control/book_selection_ui
@onready var book: Node3D = $Control/touch_controls/Book_2D/book_viewport/Book
@onready var book_2d: SubViewportContainer = $Control/touch_controls/Book_2D

var active_spell := ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Signals.connect("book_changed", book_changed)
	Signals.connect("spell_chanted", _on_spell_chanted)
	Signals.connect("magic_word_pressed", _on_magic_word_pressed)

func _on_spell_chanted(spell: String) -> void:
	active_spell = spell
	print("active_spell: ", spell)
	
func _on_magic_word_pressed(word: String) -> void:
	if active_spell != "":
		print(word)

func book_changed() -> void:
	$Control/touch_controls/book_b.show()
	book.content = SceneManager.current_book
	book.setup()
	book_2d.visible = true

func _on_return_to_main_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_room.tscn")

func _on_books_shelf_pressed() -> void:
	book_selection_ui.show()

func _on_book_b_pressed() -> void:
	book_2d.visible = false
