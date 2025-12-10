extends Node3D

@export var hide_distance: float = 10
@onready var walls: Array = $new_main_room_walls.get_children()

var hidden_walls: Array[Node3D]
var pending_shows: Dictionary = {} # Key: Node3D (Wall), Value: bool
const SHOW_DELAY: float = 0.5


var pos := Vector3(0.0, 0.0, 0.0)

func _ready() -> void:
	for wall: Node in walls: add_to_group("walls")
	Signals.connect("hide_wall", hide_wall)


func hide_wall(wall: Node3D) -> void:
	if wall == null: #show all walls
		#print("showing all walls (delayed)")
		for w: Node3D in hidden_walls.duplicate():
			_schedule_show(w)
		hidden_walls.clear()
		return
	else:
		if pending_shows.has(wall):
			pending_shows.erase(wall) 
		if wall in hidden_walls:
			return
			
		hidden_walls.append(wall)
		wall.visible = false
		wall.process_mode = Node.PROCESS_MODE_DISABLED

func _schedule_show(wall: Node3D) -> void:
	if pending_shows.has(wall):
		return
		
	pending_shows[wall] = true
	
	await get_tree().create_timer(SHOW_DELAY).timeout
	if not pending_shows.has(wall):
		return
	wall.visible = true
	wall.process_mode = Node.PROCESS_MODE_INHERIT
	pending_shows.erase(wall)
