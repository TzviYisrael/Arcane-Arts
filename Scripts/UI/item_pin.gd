extends Node2D

@export var item: Item

@onready var icon: Sprite2D = $icon

func _ready() -> void:
	icon.texture = item.icon
	
func _draw() -> void:
	var center := Vector2(0, 0) 
	var radius: int = 20

	draw_circle(center, radius, item.color)


func _on_button_button_down() -> void:
	Signals.emit_signal("item_moved", item)
	SceneManager.placed_item.erase(position)
	queue_free()
