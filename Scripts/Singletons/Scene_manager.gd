extends Node

var mage: Node
var current_book: BookContent

var placed_item: Dictionary[Vector2, Item]

func set_mage(mage_node: Node) -> void:
	mage = mage_node
