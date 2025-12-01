extends Control

@export var items: Array[Item]

@onready var natural: GridContainer = $natural
@onready var mystic: GridContainer = $mystic
@onready var demonic: GridContainer = $demonic

@export var Inventory_item_slot_scene: PackedScene

func _ready() -> void:
	for item_key: String in GameData.items_data.keys():
		var item: Item = GameData.items_data[item_key]
		var new_slot: Control = Inventory_item_slot_scene.instantiate()
		match item.origin:
			0:
				natural.add_child(new_slot)
			1:
				mystic.add_child(new_slot)
			2:
				demonic.add_child(new_slot)
		new_slot.init_item(item)
