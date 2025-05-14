extends Control

@onready var scroll_container: ScrollContainer = $ScrollContainer
@onready var h_box_container: HBoxContainer = $ScrollContainer/HBoxContainer

func _input(_event: InputEvent) -> void:
	#print(scroll_container.scroll_horizontal)
	for book in h_box_container.get_children():
	
		var half_width: float = scroll_container.size.x / 2.0
		var x_position: float = book.global_position.x - half_width
		var factor = clamp(abs(x_position) / half_width, 0.0, 1.0)
		book.update_rotation(factor)
