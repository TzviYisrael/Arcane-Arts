extends Node3D

const RAYCAST_MAX_D = 1000
@onready var button_con: VBoxContainer = $Control/touch_controls/VBoxContainer
@onready var massege: Label = $Control/touch_controls/massege

@onready var mage: CharacterBody3D = $Mage
var summoned: Node3D

var input_coll_saver: Node3D = null
var drag: bool = false
var scene_path_to_enter: String = ""

@onready var root: Node3D = $"."
@onready var summoning_floor: StaticBody3D = $NavigationRegion3D/summoning_floor
@onready var smoke_puff: GPUParticles3D = $NavigationRegion3D/summoning_floor/smoke_puff
@onready var camera_spring_arm: SpringArm3D = $camera_spring_arm
@onready var gpu_ink_circle: Sprite3D = $NavigationRegion3D/summoning_floor/gpu_ink_circle
@onready var work_desk: StaticBody3D = $NavigationRegion3D/work_desk

@onready var init_material: ShaderMaterial = load("res://Assets/shaders/init.tres")
@onready var clear_material: ShaderMaterial = load("res://Assets/shaders/clear.tres")

enum states{ROOM, RITUAL_READY, RITUAL_STARTED, GRAPPLE, CAPTURED}
@export_enum("room", "ritual_ready", "ritual_started", "grapple", "captured")
var state: int = 0

var frame_counter: int = 0
var max_green: int = 0

func _ready() -> void:
	Signals.connect("init_ritual", init_ritual)
	Signals.connect("breach", breach)
	Signals.connect("spell_chanted", _on_spell_chanted)
	
	mage.navigation_agent_3d.navigation_finished.connect(destination_reached)
	
	Signals.emit_signal("view_angle_changed",-camera_spring_arm.rotation.y + PI)
	
	state = states.ROOM
	if TextureManager.ink_circle:
		var ink := ImageTexture.create_from_image(TextureManager.ink_circle)
		#ink_circle.texture = ink
		gpu_ink_circle.set_ca_texture(ink)
	
	if TextureManager.chalk_line:
		var chalk := ImageTexture.create_from_image(TextureManager.chalk_line)
		work_desk.find_child("chalk").texture = chalk
	
	#if SceneManager.current_book:
		#book.content = SceneManager.current_book
		#book.setup()
		#$Control/touch_controls/book_b.show()

func _process(_delta: float) -> void:
	if state == states.RITUAL_STARTED || state == states.GRAPPLE:
		frame_counter += 1
		if frame_counter >= 12:
			frame_counter = 0
			var current_green : int = await gpu_ink_circle.count_color(Color.GREEN)
			if current_green >= max_green: 
				max_green = current_green
			else: 
				Signals.emit_signal("breach")
	

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenDrag:
		#set input_coll_saver to random node so it will not register as press
		input_coll_saver = camera_spring_arm 
		rotate_camera(-event.screen_relative.x / 10)

	if event is InputEventScreenTouch:
		if event.pressed:
			if not input_coll_saver:
				input_coll_saver = get_camera_ray_collider(event.position)[1]
		else:
			_handle_release_at(event.position)
			input_coll_saver = null

func _handle_release_at(pos: Vector2) -> void:
	var ret_arr: Array = get_camera_ray_collider(pos)
	var coll_pos: Vector3 = ret_arr[0]
	var coll: Node = ret_arr[1]
	#print("coll:",coll.name)
	if coll and coll.is_in_group("tap_to_enter") and coll == input_coll_saver:
		var path: String = coll.get_meta("scene_path")
		scene_path_to_enter = path
		if path == "summon":
			Signals.emit_signal("walk_destination", 
				summoning_floor.mage_circle.global_position)
		else:
			Signals.emit_signal("walk_destination", coll_pos)
	else:
		scene_path_to_enter = ""
		if input_coll_saver != camera_spring_arm:
			Signals.emit_signal("walk_destination", coll_pos)

func get_camera_ray_collider(pos: Vector2) -> Array:
	var space: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var start: Vector3 = get_viewport().get_camera_3d().project_ray_origin(pos)
	var end: Vector3 = get_viewport().get_camera_3d().project_position(pos, RAYCAST_MAX_D)
	var params := PhysicsRayQueryParameters3D.new()
	params.from = start
	params.to = end

	var coll_dict: Dictionary = space.intersect_ray(params)
	if (coll_dict != null) and (coll_dict.size() != 0):
		var coll: Node3D = coll_dict["collider"]
		return [coll_dict["position"], coll]
	else:
		return [coll_dict["position"], null]

func rotate_camera(deg: float) -> void:
	camera_spring_arm.rotate_y(deg_to_rad(deg))
	Signals.emit_signal("view_angle_changed",-camera_spring_arm.rotation.y + PI)

func destination_reached() -> void:
	#print("destination reached: ", scene_path_to_enter)
	if scene_path_to_enter == "summon":
		state = states.RITUAL_READY
		Signals.emit_signal("change_notebook_page", "summon")
	elif scene_path_to_enter != "":
		print("entering: ", scene_path_to_enter)
		get_tree().change_scene_to_file(scene_path_to_enter)
	elif state == states.RITUAL_READY:
		state = states.ROOM
		Signals.emit_signal("change_notebook_page", "room_spells")

func init_ritual(_category: int) -> void:
	#var summons_res: Dictionary = {
		#"bull": "res://GameData/resources/summons/bull.tres",
		#"ink_toad": "res://GameData/resources/summons/ink_toad.tres",
		#"eye_demon": "res://GameData/resources/summons/eye_demon.tres"
	#}
	if not summoned == null: print("existing summon"); return
	if not TextureManager.ink_circle: print("no circle"); return
	if not state == states.RITUAL_READY: print("wrong state"); return
	
	mage.anim_state.travel("summon")
	
	var positions_array := []
	var colors_array := []
	for pos: Vector2 in gpu_ink_circle.items_points:
		positions_array.append(pos)
		colors_array.append(gpu_ink_circle.items_points[pos])
	init_material.set_shader_parameter("circle_count", positions_array.size())
	init_material.set_shader_parameter("circle_positions", positions_array)
	init_material.set_shader_parameter("circle_colors", colors_array)
	
	gpu_ink_circle.one_shot_shader(init_material, 1)
	await get_tree().process_frame
	print("init ritual")
	state = states.RITUAL_STARTED
	Signals.emit_signal("change_ca_state", true)
	
func summon() -> void:
	if not summoned == null: print("existing summon"); return
	if not state == states.RITUAL_STARTED: print("wrong state"); return
	
	var summons_res: Dictionary = {
		"bull": "res://GameData/resources/summons/bull.tres",
		"ink_toad": "res://GameData/resources/summons/ink_toad.tres",
		"eye_demon": "res://GameData/resources/summons/eye_demon.tres"
	}
	
	var power : float = await gpu_ink_circle.count_color(Color.RED)
	prints("power:", power)
	var answering_summon : Node3D = null
	var answer : int = -1
	if power < 20: prints("too low power", power)
	elif 20 <= power && power < 50: answer = SummonData.CATEGORY.ANIMAL
	elif 50 <= power && power < 100: answer = SummonData.CATEGORY.MONSTER
	elif 100 <= power && power < 150: answer = SummonData.CATEGORY.DEMON
	else: prints("too high power", power)
	
	var scene: Resource
	var summon_name: String
	match answer:
		SummonData.CATEGORY.ANIMAL:
			scene = load("res://Scenes/summons/animal.tscn")
			summon_name = "bull"
		SummonData.CATEGORY.MONSTER:
			scene = load("res://Scenes/summons/monster.tscn")
			summon_name = "ink_toad"
		SummonData.CATEGORY.DEMON:
			scene = load("res://Scenes/summons/demon.tscn")
			summon_name = "eye_demon"
	
	if not answer == -1:
		answering_summon = scene.instantiate()
		answering_summon.data = load(summons_res[summon_name])
		print("fight!")
		smoke_puff.emitting = true
		summoned = answering_summon
		summoned.position = gpu_ink_circle.global_position
		summoned.look_at_from_position(gpu_ink_circle.global_position, mage.global_position) 
		root.add_child(summoned)
		state = states.GRAPPLE
	else:
		print("no fight")
		smoke_puff.emitting = true

func breach() -> void:
	print("game over")
	massege.show()
	root.process_mode = Node.PROCESS_MODE_DISABLED

func clean_texture() -> void:
	state = states.RITUAL_READY
	gpu_ink_circle.one_shot_shader(clear_material, 5)
	await get_tree().process_frame
	print("clear")

func release_summon() -> void:
	if summoned:
		summoned.queue_free()
		summoned = null
	state = states.RITUAL_READY
	#summon_power = 0
	Signals.emit_signal("change_ca_state", false)

func kill_summon() -> void:
	#gpu_ink_circle.count_color(Color.RED)
	#gpu_ink_circle.save_small_image()
	if summoned:
		prints("loot: ", summoned.data.loot.pick_random())
	release_summon()

func _on_return_b_pressed() -> void:
	root.process_mode = Node.PROCESS_MODE_INHERIT
	get_tree().reload_current_scene()

func _on_spell_chanted(spell: String) -> void:
	match spell:
		"Terra Vinculum": init_ritual(SummonData.CATEGORY.ANIMAL)
		"Astralis Vinculum": init_ritual(SummonData.CATEGORY.MONSTER)
		"Infernum Vinculum": init_ritual(SummonData.CATEGORY.DEMON)
		"Evoco Vos": summon()
		"kill": kill_summon()
		"release": release_summon()
		"clear": clean_texture()
		_: prints("the spell", spell.to_upper(), "is unknown in", 
		get_tree().get_current_scene())
