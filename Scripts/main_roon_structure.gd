extends Node3D

@export var start_angle_to_hide: float
@export var amount: int

@onready var main_room_walls: Array = $main_room_walls.get_children()

var wall_directions := [-22.5, 45-22.5, 90-22.5, 135-22.5,
 180-22.5, 225-22.5, 270-22.5, 315-22.5].map(deg_to_rad)
#var wall_directions := [0, 45, 90, 135, 180, 225, 270, 315].map(deg_to_rad)
#var v: float = 0

func _ready() -> void:
	Signals.connect("view_angle_changed", hide_walls_in_view)
	hide_walls_in_view(start_angle_to_hide)

#func _process(_delta: float) -> void:
	#v += PI / 60
	#hide_walls_in_view(v)

func hide_walls_in_view(v_angle: float) -> void:
	prints(v_angle, rotation.y)
	var hide_range: float = deg_to_rad(22.5 * amount)
	for i in main_room_walls.size():
		var diff: float = abs(wrapf((v_angle + rotation.y) -wall_directions[i], -PI, PI))
		main_room_walls[i].visible = diff > hide_range
