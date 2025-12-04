extends Control

#@export var items: Array[Item]
@export var inventory_item_slot_scene: PackedScene

@onready var natural: GridContainer = $natural
@onready var mystic: GridContainer = $mystic
@onready var demonic: GridContainer = $demonic

var item_slots: Dictionary[String, Control]

func _ready() -> void:
	Signals.connect("add_to_inventory", add_to_inventory)
	
	for item_key: String in GameData.items_data.keys():
		var item: Item = GameData.items_data[item_key]
		var new_slot: Control = inventory_item_slot_scene.instantiate()
		match item.origin:
			0:
				natural.add_child(new_slot)
			1:
				mystic.add_child(new_slot)
			2:
				demonic.add_child(new_slot)
		new_slot.init_item(item)
		item_slots[item.name] = new_slot

func add_to_inventory(item_name: String, amount: int) -> void:
	if SceneManager.inventory[item_name] + amount < 0:
		print("ERROR: negative amount of items")
		return 
	SceneManager.inventory[item_name] += amount
	item_slots[item_name].update_amount()
