extends Node2D

@onready var book_selection_ui: Control = $Control/book_selection_ui
@onready var book: Node3D = $Control/touch_controls/Book_2D/book_viewport/Book
@onready var book_2d: SubViewportContainer = $Control/touch_controls/Book_2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Signals.connect("book_changed", book_changed)

func _on_spell_chanted(spell: String) -> void:
	match spell:
		_: prints("error, unknown spell in", 
		get_tree().get_current_scene())

func book_changed() -> void:
	$Control/touch_controls/book_b.show()
	book.content = SceneManager.current_book
	book.setup()


func _on_book_b_toggled(toggled_on: bool) -> void:
	book_2d.visible = (toggled_on)


func _on_return_to_main_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_room.tscn")


func _on_books_shelf_pressed() -> void:
	book_selection_ui.show()
