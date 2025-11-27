extends Node3D

@export var hide_distance: float = 10
@onready var walls: Array = $new_main_room_walls.get_children()

var hidden_wall: Node3D

var pos := Vector3(0.0, 0.0, 0.0)

func _ready() -> void:
	for wall: Node in walls: add_to_group("walls")
	Signals.connect("hide_wall", hide_wall)

func show_all_walls() -> void:
	for i in walls.size():
		walls[i].show()

func hide_wall(wall: Node3D) -> void:
	print(wall)
	if not wall:
		if hidden_wall:
			hidden_wall.visible = true
			hidden_wall = null
	else:
		if hidden_wall:
			hidden_wall.visible = true
		hidden_wall = wall
		hidden_wall.visible = false
		
	
		
