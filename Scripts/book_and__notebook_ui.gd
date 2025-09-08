extends Control

@onready var book_container: SubViewportContainer = $book_2D
@onready var book: Node3D = $book_2D/book_viewport/Book
@onready var book_button: Button = $book_button

@onready var notebook: Control = $notebook
@onready var notebook_button: Button = $notebook_button

@onready var item_list: Control = $"item stack"
@onready var item_list_button: Button = $items_button

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
	notebook.page = notebook_page
	notebook.set_page()

func _on_book_button_toggled(toggled_on: bool) -> void:
	if SceneManager.current_book != null:
		book_container.visible = toggled_on
#
#
#func _on_notebook_button_toggled(toggled_on: bool) -> void:
	#notebook.visible = toggled_on
	#item_list.visible = false
	#notebook.mouse_filter = Control.MOUSE_FILTER_STOP \
	 #if toggled_on else Control.MOUSE_FILTER_PASS
#
#
#func _on_items_button_toggled(toggled_on: bool) -> void:
	#item_list.visible = toggled_on
	#notebook.visible = false
	#item_list.mouse_filter = Control.MOUSE_FILTER_STOP \
	 #if toggled_on else Control.MOUSE_FILTER_PASS

#func _on_book_button_pressed() -> void:
	#if SceneManager.current_book != null:
		#book_container.visible = not book_container.visible
		#notebook.visible = false
		#item_list.visible = false

func _on_items_button_pressed() -> void:
	item_list.visible = not item_list.visible
	notebook.visible = false
	#book_container.visible = false
	item_list.mouse_filter = Control.MOUSE_FILTER_STOP \
	 if item_list.visible else Control.MOUSE_FILTER_PASS

func _on_notebook_button_pressed() -> void:
	notebook.visible = not notebook.visible
	item_list.visible = false
	#book_container.visible = false
	notebook.mouse_filter = Control.MOUSE_FILTER_STOP \
	 if notebook.visible else Control.MOUSE_FILTER_PASS
