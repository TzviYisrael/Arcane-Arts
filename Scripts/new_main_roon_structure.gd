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
	for i in walls.size():
		var dis: float = camera_pos.distance_to(walls[i].position)
		walls[i].visible = dis > hide_distance
