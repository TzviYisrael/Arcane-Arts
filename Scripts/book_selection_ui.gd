extends Control

@onready var scroll_container: ScrollContainer = $ScrollContainer
@onready var h_box_container: HBoxContainer = $ScrollContainer/HBoxContainer

func _ready() -> void:
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
