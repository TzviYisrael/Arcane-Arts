extends Node3D

var mouse = Vector2()
const MAX_D = 1000 

@onready var decal: Decal = $Decal

func _ready() -> void:
	if TextureManager.chalk_line:
		var chalk = ImageTexture.create_from_image(TextureManager.chalk_line)
		decal.texture_albedo = chalk
		decal.texture_normal = chalk
	else:
		decal.texture_albedo = null
		decal.texture_normal = null

func _process(delta: float) -> void:
	decal.rotation.y += deg_to_rad(1)
	
	
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
		get_tree().change_scene_to_file(coll.get_meta("scene_path"))
		#print(coll)
