extends Node3D

var mouse = Vector2()
const MAX_D = 1000
@onready var button_con: VBoxContainer = $Control/touch_controls/VBoxContainer

@onready var mage: CharacterBody3D = $Mage
var summoned: Node3D
var run_sim: bool

@onready var root: Node3D = $"."
@onready var summoning_table: StaticBody3D = $summoning_table
@onready var work_desk: StaticBody3D = $work_desk

enum states{ROOM, SUMMONING, CAPTURED}
@export_enum("room", "summoning", "captured") var state: int = 0;

func _ready() -> void:
	Signals.connect("start_summon", start_summon)
	Signals.connect("enter_summon_floor", enter_summon_floor)
	
	state = states.ROOM	
	ui_change_state(state)
	
	if TextureManager.chalk_line:
		var chalk = ImageTexture.create_from_image(TextureManager.chalk_line)
		work_desk.find_child("chalk").texture = chalk
	else:
		pass

func _process(delta: float) -> void:
	if TextureManager.ink_circle && run_sim:
		Ink_circle.ca_genretion(TextureManager.ink_circle)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse = event.position
	if event is InputEventMouseButton:
		if event.pressed == false and event.button_index == MOUSE_BUTTON_LEFT:
			var coll = get_mouse_collider(mouse)
			if coll and coll.is_in_group("tap_to_enter"):
				var path =  coll.get_meta("scene_path")
				if path == "summon":
					Signals.emit_signal("start_summon")
				else:
					get_tree().change_scene_to_file(path)

func get_mouse_collider(_mouse:Vector2) -> Node:
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
		return coll
	else:
		return null

func ui_change_state(_state: int):
	match _state:
		states.ROOM:
			button_con.hide()
		states.SUMMONING:
			button_con.show()
			button_con.find_child("summon_b").show()
			button_con.find_child("kill_b").hide()
			button_con.find_child("release_b").hide()
		states.CAPTURED:
			button_con.show()
			button_con.find_child("summon_b").hide()
			button_con.find_child("kill_b").show()
			button_con.find_child("release_b").show()

func enter_summon_floor():
	state = states.SUMMONING
	ui_change_state(state)
	mage.position = summoning_table.find_child("mage_circle").global_position
	mage.find_child("Rig").rotation.y = summoning_table.rotation.y + PI / 2
	mage.find_child("SpringArm3D").rotation.y = summoning_table.rotation.y + PI / 2

func start_summon() -> void:
	if TextureManager.ink_circle:
		run_sim = true
		#var count_ink = Ink_circle.count_color(TextureManager.ink_circle, Color.BLACK)
		#print(count_ink)
		#if count_ink > 2000:
			#print("bull")
			#var scene = preload("res://Scenes/bull.tscn")
			#summoned = scene.instantiate()
			#summoned.position = summoning_table.decal.global_position
			#root.add_child(summoned)
			#state = states.CAPTURED
			#ui_change_state(state)
		#else:
			#print("nope")
	else:
		print("no circle")

func _on_summon_b_pressed() -> void:
	start_summon()

func _on_release_b_pressed() -> void:
	if summoned:
		summoned.queue_free()
	state = states.SUMMONING
	ui_change_state(state)

func _on_kill_b_pressed() -> void:
	_on_release_b_pressed()
