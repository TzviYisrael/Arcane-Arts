extends Node3D

var mouse = Vector2()
const MAX_D = 1000 
@onready var mage: CharacterBody3D = $Mage
@onready var summoning_table: StaticBody3D = $summoning_table

@onready var work_desk: StaticBody3D = $work_desk

func _ready() -> void:
	Signals.connect("enter_summon_floor", enter_summon_floor)
	
	if TextureManager.chalk_line:
		var chalk = ImageTexture.create_from_image(TextureManager.chalk_line)
		work_desk.find_child("chalk").texture = chalk
	else:
		pass#print("chalk null")

func _unhandled_input(event: InputEvent) -> void:
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
	
	var coll = space.intersect_ray(params)
	if (coll != null) and (coll.size() != 0):
		coll = coll["collider"]
		print(coll.name)
		if coll.is_in_group("tap_to_enter"):
			get_tree().change_scene_to_file(coll.get_meta("scene_path"))
			#print(coll)

func enter_summon_floor():
	print("123")
	mage.position = summoning_table.find_child("mage_circle").global_position
