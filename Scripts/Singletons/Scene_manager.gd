extends Node

#global data
var summons_array: Array[SummonData]

#main room
var mage: Node
var mage_pos: Vector3 = Vector3(7.733, 0.192, 0.802)
var mage_rot: Vector3 = Vector3(0.0, 0.0, 0.0)

var placed_item: Dictionary[Vector2, Item]

#drawing desk
var drawing_desk_current_tool: int = 1

#summoning floor
var brush_size: int
var summoning_floor_current_tool: int = 1

#ui
var current_book: BookContent

func set_mage(mage_node: Node) -> void:
	mage = mage_node

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		print("saving...")
		get_tree().quit()
