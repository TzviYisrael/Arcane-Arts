extends AspectRatioContainer

@export var item: Item
@onready var button: TextureButton = $Button
@onready var texture_rect: TextureRect = $TextureRect
@onready var label: Label = $Label

func _ready() -> void:
	pass # Replace with function body.

func init_item(new_item: Item) -> void:
	item = new_item
	texture_rect.texture = item.icon
	label.text = item.name

func item_botton_pressed() -> void:
	print("item pressed: ", item.name)
	Signals.emit_signal("item_moved", item)
