extends Node

var mage: Node
var current_book: BookContent = load("res://GameData/resources/books/the_princces_bride.tres")

func set_mage(mage_node: Node) -> void:
	mage = mage_node
