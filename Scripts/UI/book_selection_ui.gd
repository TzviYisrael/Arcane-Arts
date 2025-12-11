extends Control

const BOOK_3D = preload("res://Scenes/3D/book_3D.tscn")
@onready var scroll_container: ScrollContainer = $ScrollContainer
@onready var h_box_container: HBoxContainer = $ScrollContainer/HBoxContainer

func _ready() -> void:
	if not GameData.books_data.is_empty():
		for book_name: String in GameData.books_data:
			var new_book := BOOK_3D.instantiate()
			new_book.book_data = GameData.books_data[book_name]
			h_box_container.add_child(new_book)
		h_box_container.move_child($ScrollContainer/HBoxContainer/VSeparator_end, h_box_container.get_child_count())
		update_books_rotation()

func _input(_event: InputEvent) -> void:
	update_books_rotation()

func update_books_rotation() -> void:
	for book in h_box_container.get_children():
		if book is VSeparator: continue
		var half_width: float = scroll_container.size.x / 2.0
		var x_position: float = book.global_position.x - half_width
		var factor: float = clamp(abs(x_position) / half_width, 0.0, 1.0)
		book.update_rotation(factor)

func _on_button_pressed() -> void:
	hide()
