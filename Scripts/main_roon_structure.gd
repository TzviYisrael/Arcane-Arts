extends Node3D

@export var view_angle_range_deg: float = 120.0

@onready var main_room_walls: Array = $main_room_walls.get_children()

var wall_directions := [45, 90, 135, 180,
 225, 270, 315, 360].map(deg_to_rad)

func _ready() -> void:
	Signals.connect("view_angle_changed", hide_walls_in_view)

func show_all_walls() -> void:
	for i in main_room_walls.size():
		main_room_walls[i].show()

## hide the walls that in range of v_angle (in radians)
func hide_walls_in_view(v_angle: float) -> void:
	var half_range_rad:float = deg_to_rad(view_angle_range_deg / 2.0)

	for i in main_room_walls.size():
		var wall_angle: float = wall_directions[i]
		var angle_diff: float = abs(wrapf(wall_angle - v_angle, -PI, PI))
		main_room_walls[i].visible = angle_diff > half_range_rad
