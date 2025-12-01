extends Node

#global
var invantory: Dictionary[String, int]

#mage
var camera_rot_deg:= Vector3(-30.0, 0.0, 0.0)

#main room
var mage: Node
var mage_pos := Vector3(10, 0.192, -5)
var mage_rot := Vector3(0.0, 0.0, 0.0)


var placed_item: Dictionary[Vector2, Item]

#drawing desk
var drawing_desk_current_tool: int = 1

#summoning floor
var summoning_floor_brush_size: float = 0.29
var summoning_floor_current_tool: int = 1

#ui
var current_book: BookContent

func set_mage(mage_node: Node) -> void:
	mage = mage_node

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		print("saving...")
		get_tree().quit()
