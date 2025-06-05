extends Control

@onready var book_container: SubViewportContainer = $book_2D
@onready var book: Node3D = $book_2D/book_viewport/Book
@onready var book_button: Button = $book_button

@onready var notebook: Control = $notebook
@onready var notebook_button: Button = $notebook_button

@export_enum("summon", "summon_spells",
 "room_spells", "chalkboard", "floor") var notebook_page: int
@export var show_book: bool = false
@export var show_notebook: bool = false

func _ready() -> void:
	if SceneManager.current_book:
		book.content = SceneManager.current_book
		book.setup()
		book_button.show()
	
	book_container.visible = show_book
	_on_notebook_button_toggled(show_notebook)
	notebook.page = notebook_page
	notebook.set_page()

func _on_book_button_toggled(toggled_on: bool) -> void:
	if SceneManager.current_book != null:
		book_container.visible = toggled_on


func _on_notebook_button_toggled(toggled_on: bool) -> void:
	notebook.visible = toggled_on
	notebook.mouse_filter = Control.MOUSE_FILTER_STOP \
	 if toggled_on else Control.MOUSE_FILTER_PASS
