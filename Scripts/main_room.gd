extends Node3D

var mouse = Vector2()
const MAX_D = 1000 
@onready var t = $work_desk
func _input(event:InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse = event.position
	if event is InputEventMouseButton:
		if event.pressed == false and event.button_index == MOUSE_BUTTON_LEFT:
			get_mouse_world_pos(mouse)


func get_mouse_world_pos(_mouse:Vector2):
	var space = get_world_3d().direct_space_state
	var start = get_viewport().get_camera_3d().project_ray_origin(_mouse)
	var end = get_viewport().get_camera_3d().project_position(mouse, MAX_D)
	var params = PhysicsRayQueryParameters3D.new()
	params.from = start
	params.to = end
	
	var coll = space.intersect_ray(params)["collider"]
	print(coll)
	if coll.is_in_group("tap_to_enter"):
		get_tree().change_scene_to_file(t.get("scene"))
		#print(coll)
