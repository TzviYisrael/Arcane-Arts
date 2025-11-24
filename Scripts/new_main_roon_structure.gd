extends Node3D

@export var hide_distance: float = 10
@onready var walls: Array = $new_main_room_walls.get_children()

var pos := Vector3(0.0, 0.0, 0.0)

func _ready() -> void:
	Signals.connect("view_angle_changed", hide_walls_in_distance)

func show_all_walls() -> void:
	for i in walls.size():
		walls[i].show()

## hide the walls that in range of v_angle (in radians)
func hide_walls_in_distance(camera_pos: Vector3) -> void:
	for i in walls.size():
		var dis: float = camera_pos.distance_to(walls[i].position)
		walls[i].visible = dis > hide_distance
