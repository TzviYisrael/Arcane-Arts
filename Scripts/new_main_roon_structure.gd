extends Node3D

@export var hide_distance: float = 10
@onready var walls: Array = $new_main_room_walls.get_children()

var pos := Vector3(0.0, 0.0, 0.0)

func _ready() -> void:
	Signals.connect("camera_position_changed", hide_walls_by_distance)

func show_all_walls() -> void:
	for i in walls.size():
		walls[i].show()

func hide_walls_by_distance(camera_pos: Vector3) -> void:
	var _str: String = ""
	for i in walls.size():
		var wall_pos: Vector3 = walls[i].position
		var dis: float = Vector2(camera_pos.x, camera_pos.z).	distance_to(
			Vector2(wall_pos.x, wall_pos.z))
		if dis > hide_distance:
			walls[i].visible = true
		else:
			walls[i].visible = false
		_str = walls[0].name + " " + str(dis) + " " + str(walls[0].visible)
	print(_str)
