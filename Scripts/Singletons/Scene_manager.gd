extends Node

#global data
var summons_array: Array[SummonData]

#main room
var mage: Node
var mage_pos: Vector3
var mage_rot: Vector3

var placed_item: Dictionary[Vector2, Item]

#drawing desk
var drawing_desk_current_tool: int = 1

#summoning floor
var summoning_floor_current_tool: int = 1

#ui
var current_book: BookContent

func set_mage(mage_node: Node) -> void:
	mage = mage_node
