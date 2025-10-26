extends Control

@export var items: Array[Item]

@onready var natural: GridContainer = $natural
@onready var mystic: GridContainer = $mystic
@onready var demonic: GridContainer = $demonic

func _ready() -> void:
	for item_key: String in GameData.items_data.keys():
		var item: Item = GameData.items_data[item_key]
		var button := Button.new()
		button.text = item.name
		button.custom_minimum_size = Vector2(150, 150)
		button.connect("button_down", item_botton_pressed.bind(item))
		match item.origin:
			0:
				natural.add_child(button)
			1:
				mystic.add_child(button)
			2:
				demonic.add_child(button)

func item_botton_pressed(item: Item) -> void:
	Signals.emit_signal("item_moved", item)
