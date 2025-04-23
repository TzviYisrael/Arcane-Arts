extends Node3D

var mouse = Vector2()
const MAX_D = 1000
@onready var button_con: VBoxContainer = $Control/touch_controls/VBoxContainer
@onready var massege: Label = $Control/touch_controls/massege

@onready var mage: CharacterBody3D = $Mage
var summoned: Node3D
var target_summoned: Node3D
var bull_scene = preload("res://Scenes/bull.tscn")
var run_sim: bool
var target_power := 0
var summon_power := 0

@onready var root: Node3D = $"."
@onready var summoning_table: StaticBody3D = $summoning_table
@onready var smoke_puff: GPUParticles3D = $summoning_table/smoke_puff
@onready var ink_circle: Sprite3D = $summoning_table/ink_circle2

@onready var work_desk: StaticBody3D = $work_desk

enum states{ROOM, SUMMONING, CAPTURED}
@export_enum("room", "summoning", "captured") var state: int = 0;

func _ready() -> void:
	Signals.connect("init_summon", init_summon)
	Signals.connect("enter_summon_floor", enter_summon_floor)
	Signals.connect("add_summon_power", add_summon_power)
	Signals.connect("breach", breach)
	
	state = states.ROOM	
	ui_change_state(state)
	
	#ink_circle.position = summoning_table.find_child("ink_circle").global_position
	if TextureManager.ink_circle:
		var ink = ImageTexture.create_from_image(TextureManager.ink_circle)
		ink_circle.texture = ink
	
	if TextureManager.chalk_line:
		var chalk = ImageTexture.create_from_image(TextureManager.chalk_line)
		work_desk.find_child("chalk").texture = chalk

func _process(delta: float) -> void:
	if run_sim and TextureManager.ink_circle:
		run_sim = Ink_circle.fast_ca_genretion(TextureManager.ink_circle)
		update_texture()
	
	if run_sim and summon_power >= target_power and state == states.SUMMONING:
		print("fight!")
		smoke_puff.emitting = true
		summoned = target_summoned
		summoned.position = ink_circle.global_position
		summoned.look_at_from_position(ink_circle.global_position, mage.global_position) 
		root.add_child(summoned)
		state = states.CAPTURED
		ui_change_state(state)

#func _unhandled_input(event: InputEvent) -> void:
	#if event is InputEventMouseMotion:
		#mouse = event.position
	#if event is InputEventMouseButton:
		#if event.pressed == false and event.button_index == MOUSE_BUTTON_LEFT:
			#var coll = get_mouse_collider(mouse)
			#if coll and coll.is_in_group("tap_to_enter"):
				#var path =  coll.get_meta("scene_path")
				#if path == "summon":
					#Signals.emit_signal("start_summon")
				#else:
					#get_tree().change_scene_to_file(path)
#
#func get_mouse_collider(_mouse:Vector2) -> Node:
	#var space = get_world_3d().direct_space_state
	#var start = get_viewport().get_camera_3d().project_ray_origin(_mouse)
	#var end = get_viewport().get_camera_3d().project_position(mouse, MAX_D)
	#var params = PhysicsRayQueryParameters3D.new()
	#params.from = start
	#params.to = end
	#
	#var coll = space.intersect_ray(params)
	#if (coll != null) and (coll.size() != 0):
		#coll = coll["collider"]
		#print("ray coll: ", coll.name)
		#return coll
	#else:
		#return null

func _unhandled_input(event: InputEvent) -> void:
	# Track pointer position (mouse or touch)
	if event is InputEventMouseMotion:
		mouse = event.position
	elif event is InputEventScreenDrag:
		mouse = event.position

	# Handle tap or mouse click
	if event is InputEventMouseButton:
		if not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_handle_pressed_at(event.position)
	elif event is InputEventScreenTouch:
		if not event.pressed:
			_handle_pressed_at(event.position)

func _handle_pressed_at(pos: Vector2) -> void:
	var coll = get_mouse_collider(pos)
	if coll and coll.is_in_group("tap_to_enter"):
		var path = coll.get_meta("scene_path")
		if path == "summon":
			Signals.emit_signal("start_summon")
		else:
			get_tree().change_scene_to_file(path)

func get_mouse_collider(_mouse: Vector2) -> Node:
	var space = get_world_3d().direct_space_state
	var start = get_viewport().get_camera_3d().project_ray_origin(_mouse)
	var end = get_viewport().get_camera_3d().project_position(_mouse, MAX_D)
	var params = PhysicsRayQueryParameters3D.new()
	params.from = start
	params.to = end

	var coll = space.intersect_ray(params)
	if (coll != null) and (coll.size() != 0):
		coll = coll["collider"]
		print("ray coll: ", coll.name)
		return coll
	else:
		return null


func ui_change_state(_state: int):
	match _state:
		states.ROOM:
			button_con.hide()
		states.SUMMONING:
			button_con.show()
			#button_con.find_child("load_ink_b").show()
			button_con.find_child("summon_b").show()
			button_con.find_child("kill_b").hide()
			button_con.find_child("release_b").hide()
		states.CAPTURED:
			button_con.show()
			#button_con.find_child("load_ink_b").hide()
			button_con.find_child("summon_b").hide()
			button_con.find_child("kill_b").show()
			button_con.find_child("release_b").show()

func enter_summon_floor():
	state = states.SUMMONING
	ui_change_state(state)
	mage.position = summoning_table.find_child("mage_circle").global_position
	mage.find_child("Rig").rotation.y = summoning_table.rotation.y + PI / 2
	mage.find_child("SpringArm3D").rotation.y = \
	summoning_table.rotation.y + PI / 2

func init_summon() -> void:
	if TextureManager.ink_circle:
		Ink_circle.init_ink_colors(TextureManager.ink_circle)
		TextureManager.surface_pos.clear()
		update_texture()
		target_summoned = bull_scene.instantiate()
		target_power = target_summoned.power
		run_sim = true
		
	else:
		print("no circle")

func add_summon_power(power: int):
	summon_power += power
	prints("summon_power:", summon_power)

func breach(pos):
	run_sim = false
	print("game over", pos)
	massege.show()
	root.process_mode = Node.PROCESS_MODE_DISABLED

func update_texture():
	ink_circle.texture.update(TextureManager.ink_circle)

func _on_summon_b_pressed() -> void:
	init_summon()

func _on_release_b_pressed() -> void:
	if summoned:
		summoned.queue_free()
		summoned = null
	state = states.SUMMONING
	ui_change_state(state)
	summon_power = 0
	run_sim = false

func _on_kill_b_pressed() -> void:
	_on_release_b_pressed()

func _on_return_b_pressed() -> void:
	root.process_mode = Node.PROCESS_MODE_INHERIT
	get_tree().reload_current_scene()

func _on_load_ink_pressed() -> void:
	if TextureManager.ink_circle:
		pass
