extends Node3D

const RAYCAST_MAX_D = 1000
@onready var button_con: VBoxContainer = $Control/touch_controls/VBoxContainer
@onready var massege: Label = $Control/touch_controls/massege

@onready var mage: CharacterBody3D = $Mage
var summoned: Node3D

var item_amount: int = 0
#@export var item: Item

var input_coll_saver: Node3D = null
var drag: bool = false
var scene_path_to_enter: String = ""

@onready var root: Node3D = $"."
@onready var summoning_floor: StaticBody3D = $NavigationRegion3D/summoning_floor
@onready var smoke_puff: GPUParticles3D = $NavigationRegion3D/summoning_floor/smoke_puff
@onready var camera_spring_arm: SpringArm3D = $camera_spring_arm
@onready var gpu_ink_circle: Sprite3D = $NavigationRegion3D/summoning_floor/gpu_ink_circle
@onready var work_desk: StaticBody3D = $NavigationRegion3D/work_desk

enum states{ROOM, RITUAL_READY, RITUAL_STARTED, GRAPPLE, CAPTURED}
@export_enum("room", "ritual_ready", "ritual_started", "grapple", "captured")
var state: int = 0

var frame_counter: int = 0
var colors_to_count: Dictionary[Color, bool] = {}
var max_green: int = 0

func _ready() -> void:
	gpu_ink_circle.process_mode = Node.PROCESS_MODE_INHERIT
	Signals.connect("start_ritual", start_ritual)
	Signals.connect("breach", breach)
	Signals.connect("spell_chanted", _on_spell_chanted)
	
	mage.position = SceneManager.mage_pos
	mage.model.rotation = SceneManager.mage_rot
	mage.navigation_agent_3d.navigation_finished.connect(destination_reached)
	
	Signals.emit_signal("view_angle_changed",-camera_spring_arm.rotation.y + PI)
	
	state = states.ROOM
	if TextureManager.ink_circle:
		var ink := ImageTexture.create_from_image(TextureManager.ink_circle)
		gpu_ink_circle.set_ca_texture(ink)
	
	if TextureManager.chalk_line:
		var chalk := ImageTexture.create_from_image(TextureManager.chalk_line)
		work_desk.find_child("chalk").texture = chalk
	
	#if SceneManager.current_book:
		#book.content = SceneManager.current_book
		#book.setup()
		#$Control/touch_controls/book_b.show()

	colors_to_count[Color.RED] = true
	colors_to_count[Color.GREEN] = true
	for p in SceneManager.placed_item:
		colors_to_count[SceneManager.placed_item[p].color] = true

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
	if ret_arr[0] == null:
		return
	var coll_pos: Vector3 = ret_arr[0]
	var coll: Node = ret_arr[1]
	#print("coll:",coll.get_parent())
	if coll and coll.get_parent().is_in_group("items"):
		print("item: ", coll.get_parent().name)
		#TODO: collect the item
	elif coll and coll.is_in_group("tap_to_enter") and coll == input_coll_saver:
		var path: String = coll.get_meta("scene_path")
		scene_path_to_enter = path
		if path == "summon_floor":
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
		return [null, null]

func rotate_camera(deg: float) -> void:
	camera_spring_arm.rotate_y(deg_to_rad(deg))
	Signals.emit_signal("view_angle_changed",-camera_spring_arm.rotation.y + PI)

func destination_reached() -> void:
	#print("destination reached: ", scene_path_to_enter)
	if scene_path_to_enter == "summon_floor":
		setup_items()
	elif scene_path_to_enter != "":
		print("entering: ", scene_path_to_enter)
		save_and_change_scene(scene_path_to_enter)
	elif state == states.RITUAL_READY:
		state = states.ROOM
		Signals.emit_signal("change_notebook_page", "room_spells")

func setup_items() -> void:
	if not item_amount == 0:
		state = states.RITUAL_READY
		Signals.emit_signal("change_notebook_page", "summon")
		return
	mage.navigation_agent_3d.navigation_finished.disconnect(destination_reached)
	
	var rotation_basis := Basis.from_euler(Vector3(0, deg_to_rad(90), 0))
	for pos: Vector2 in SceneManager.placed_item:
		var item := SceneManager.placed_item[pos]
		
		var new_item: Node3D = item.model.instantiate()
		var original_relative_pos := Vector3(pos.x, 0, pos.y) * 2.5
		var rotated_relative_pos: Vector3 = rotation_basis * original_relative_pos
		new_item.position = rotated_relative_pos
		new_item.add_to_group("items")
		
		Signals.emit_signal("walk_destination", 
			new_item.position)
		await mage.navigation_agent_3d.navigation_finished
		gpu_ink_circle.add_child(new_item)
		item_amount += 1
		
	Signals.emit_signal("walk_destination", 
		summoning_floor.mage_circle.global_position)
	await mage.navigation_agent_3d.navigation_finished
	mage.navigation_agent_3d.navigation_finished.connect(destination_reached)
	Signals.emit_signal("mage_look", gpu_ink_circle.global_position)
	state = states.RITUAL_READY
	Signals.emit_signal("change_notebook_page", "summon")

func start_ritual(_category: int) -> void:
	if not summoned == null: print("existing summon"); return
	if not TextureManager.ink_circle: print("no circle"); return
	if not state == states.RITUAL_READY: print("wrong state"); return
	mage.anim_state.travel("summon")
	
	gpu_ink_circle.init()
	await get_tree().process_frame
	
	print("start ritual")
	state = states.RITUAL_STARTED
	Signals.emit_signal("change_ca_state", true)

func summon() -> void:
	if not summoned == null: printerr("existing summon"); return
	if not state == states.RITUAL_STARTED: printerr("wrong state"); return
	
	Signals.emit_signal("summon_particles", gpu_ink_circle.global_position)
	await get_tree().create_timer(2.0).timeout 
	
	#var summons_res: Dictionary = {
		#"bull": "res://GameData/resources/summons/bull.tres",
		#"ink_toad": "res://GameData/resources/summons/ink_toad.tres",
		#"eye_demon": "res://GameData/resources/summons/eye_demon.tres"
	#}
	var colors_amount: Dictionary[Color, float]
	for color: Color in colors_to_count.keys():
		colors_amount[color] = await gpu_ink_circle.count_color(color)
	print("colors ", colors_amount)
	GameData.print_colors()
	#var power: float = color_amount[Color.RED]
	##var power : float = await gpu_ink_circle.count_color(Color.RED)
	#prints("power:", power)
	var answering_summon : Node3D = null
	var select_summoned: String = ""
	select_summoned = select_summon(colors_amount)

	if not select_summoned == "":
		print("select_summoned: ", select_summoned)
		var scene: Resource
		match GameData.summons_data[select_summoned].category:
			SummonData.CATEGORY.ANIMAL:
				scene = load("res://Scenes/summons/animal.tscn")
			SummonData.CATEGORY.MONSTER:
				scene = load("res://Scenes/summons/monster.tscn")
			SummonData.CATEGORY.DEMON:
				scene = load("res://Scenes/summons/demon.tscn")
				
		answering_summon = scene.instantiate()
		answering_summon.data = GameData.summons_data[select_summoned]
		print("fight!")
		smoke_puff.emitting = true
		summoned = answering_summon
		summoned.position = gpu_ink_circle.global_position
		summoned.look_at_from_position(gpu_ink_circle.global_position, mage.global_position) 
		root.add_child(summoned)
		clear_items()
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
	gpu_ink_circle.clear_colors()
	clear_items()
	print("clear")
	max_green = 0

func select_summon(colors: Dictionary) -> String:
	for summon_key: String in GameData.summons_data.keys():
		var color_rec: Dictionary = GameData.summons_data[summon_key].colors_rec
		if compare_color_dicts(colors, color_rec): return summon_key
		else: print(summon_key, " not selected")
	return ""

func compare_color_dicts(colors: Dictionary, color_rec: Dictionary) -> bool:
	for required_color: Color in color_rec.keys():
		if not colors.has(required_color):
			return false
			
		var required_weight: int = int(color_rec[required_color])
		var actual_weight: int = int(colors[required_color])
		
		if actual_weight < required_weight:
			return false

	return true
	
func setup_loot(loot: Array[String], pos: Vector3) -> void:
	const radius := 5
	var count: int = loot.size()
	var angle_diff: float = TAU / float(count)
	for i in range(count):
		var item: Item = GameData.items_data[loot[i]]
		if not item: print("missing loot item")
		else:
			var angle: float = angle_diff * i
			var x_offset: float = radius * cos(angle)
			var z_offset: float = radius * sin(angle)
			var item_position := Vector3(
				pos.x + x_offset, pos.y, pos.z + z_offset)

			var new_item: Node3D = item.model.instantiate()
			new_item.position = item_position
			new_item.add_to_group("items")
			gpu_ink_circle.add_child(new_item)
			item_amount += 1

func clear_items() -> void:
	for item in gpu_ink_circle.get_children():
		if item.is_in_group("items"):
			item.queue_free()
	SceneManager.placed_item.clear()

func release_summon() -> void:
	if summoned:
		summoned.queue_free()
		summoned = null
	state = states.RITUAL_READY
	#summon_power = 0
	Signals.emit_signal("change_ca_state", false)

func kill_summon() -> void:
	#gpu_ink_circle.save_small_image()
	if summoned:
		#TODO: add_to_invetory(GameData.summons_data[summoned.data.loot.pick_random()])
		print(summoned.data.loot.pick_random())
	release_summon()

func _on_return_b_pressed() -> void:
	root.process_mode = Node.PROCESS_MODE_INHERIT
	get_tree().reload_current_scene()

func _on_spell_chanted(spell: String) -> void:
	match spell:
		"Terra Vinculum": start_ritual(SummonData.CATEGORY.ANIMAL)
		"Astralis Vinculum": start_ritual(SummonData.CATEGORY.MONSTER)
		"Infernum Vinculum": start_ritual(SummonData.CATEGORY.DEMON)
		"Evoco Vos": summon()
		"kill": kill_summon()
		"release": release_summon()
		"clear": clean_texture()
		_: prints("the spell", spell.to_upper(), "is unknown in", 
		get_tree().get_current_scene())

func save_and_change_scene(scene_path: String) -> void:
	SceneManager.mage_pos = mage.position
	SceneManager.mage_rot = mage.model.rotation
	
	get_tree().change_scene_to_file(scene_path)
