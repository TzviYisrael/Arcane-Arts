extends Node3D

var mouse := Vector2()
const MAX_D = 1000
@onready var button_con: VBoxContainer = $Control/touch_controls/VBoxContainer
@onready var massege: Label = $Control/touch_controls/massege
@onready var book_container: SubViewportContainer = $Control/touch_controls/book_2D
@onready var book: Node3D = $Control/touch_controls/book_2D/book_viewport/Book

@onready var mage: CharacterBody3D = $Mage
var summoned: Node3D
var target_summoned: Node3D
var run_sim: bool
var target_power := 0
var summon_power := 0

var input_coll_saver: Node3D = null
var drag: bool = false

@onready var root: Node3D = $"."
@onready var summoning_table: StaticBody3D = $summoning_floor
@onready var smoke_puff: GPUParticles3D = $summoning_floor/smoke_puff
@onready var ink_circle: Sprite3D = $summoning_floor/ink_circle2
@onready var camera_spring_arm: SpringArm3D = $camera_spring_arm


@onready var work_desk: StaticBody3D = $work_desk

enum {PORTAL, GRAPPLE}
enum states{ROOM, RITUAL_READY, RITUAL_START, GRAPPLE, CAPTURED}
@export_enum("room", "ritual_ready", "ritual_start", "grapple", "captured")
var state: int = 0

func _ready() -> void:
	Signals.connect("init_ritual", init_ritual)
	Signals.connect("enter_summon_floor", enter_summon_floor)
	Signals.connect("add_summon_power", add_summon_power)
	Signals.connect("portal_distracted", portal_distracted)
	Signals.connect("breach", breach)
	
	state = states.ROOM
	if TextureManager.ink_circle:
		var ink := ImageTexture.create_from_image(TextureManager.ink_circle)
		ink_circle.texture = ink
	
	if TextureManager.chalk_line:
		var chalk := ImageTexture.create_from_image(TextureManager.chalk_line)
		work_desk.find_child("chalk").texture = chalk
	
	if SceneManager.current_book:
		book.content = SceneManager.current_book
		book.setup()
		$Control/touch_controls/book_b.show()

func _process(_delta: float) -> void:
	if run_sim and TextureManager.ink_circle:
		match state:
			states.ROOM: pass
			states.RITUAL_READY: pass
			states.RITUAL_START:
				run_sim = Ink_circle.fast_ca_genretion(TextureManager.ink_circle, PORTAL)
				update_texture()
			states.GRAPPLE:
				run_sim = Ink_circle.fast_ca_genretion(TextureManager.ink_circle, GRAPPLE)
				update_texture()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenDrag:
		#set input_coll_saver to random node so it will not register as press
		input_coll_saver = camera_spring_arm 
		rotate_camera(-event.screen_relative.x / 10)

	if event is InputEventScreenTouch:
		if event.pressed:
			if not input_coll_saver:
				input_coll_saver = get_camera_ray_collider(event.position)
		else:
			_handle_release_at(event.position)
			input_coll_saver = null

func _handle_release_at(pos: Vector2) -> void:
	var coll: Node = get_camera_ray_collider(pos)
	if coll and coll.is_in_group("tap_to_enter") and coll == input_coll_saver:
		print("entering: ", coll.name)
		var path: String = coll.get_meta("scene_path")
		if path == "summon":
			Signals.emit_signal("start_summon")
		else:
			get_tree().change_scene_to_file(path)

func get_camera_ray_collider(pos: Vector2) -> Node:
	var space: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var start: Vector3 = get_viewport().get_camera_3d().project_ray_origin(pos)
	var end: Vector3 = get_viewport().get_camera_3d().project_position(pos, MAX_D)
	var params := PhysicsRayQueryParameters3D.new()
	params.from = start
	params.to = end

	var coll_dict: Dictionary = space.intersect_ray(params)
	if (coll_dict != null) and (coll_dict.size() != 0):
		var coll: Node3D = coll_dict["collider"]
		#print("ray coll: ", coll.name)
		return coll
	else:
		return null

func rotate_camera(deg: float) -> void:
	camera_spring_arm.rotate_y(deg_to_rad(deg))
	Signals.emit_signal("view_angle_changed",-camera_spring_arm.rotation.y + PI)

func enter_summon_floor() -> void:
	state = states.RITUAL_READY
	mage.position = summoning_table.find_child("mage_circle").global_position
	mage.find_child("Rig").rotation.y = summoning_table.rotation.y + PI / 2


func init_ritual(category: int, summon_name: String) -> void:
	var summons_res: Dictionary = {
		"bull": "res://GameData/resources/summons/bull.tres",
		"ink_toad": "res://GameData/resources/summons/ink_toad.tres",
		"eye_demon": "res://GameData/resources/summons/eye_demon.tres"
	}
	if not summoned == null: print("existing summon"); return
	if not summon_name in summons_res: print("no such summon"); return
	if not TextureManager.ink_circle: print("no circle"); return
	if not state == states.RITUAL_READY: print("wrong state"); return
	
	mage.anim_state.travel("summon")
	var param := Ink_circle.island_counter(TextureManager.ink_circle)
	prints("island_counter:",param)
	Ink_circle.init_ink_colors(TextureManager.ink_circle)
	TextureManager.surface_pos.clear()
	update_texture()
	
	#target_summoned = bull_scene.instantiate()
	#target_power = target_summoned.power
	var scene: Resource
	match category:
		SummonData.CATEGORY.ANIMAL:
			scene = load("res://Scenes/summons/animal.tscn")
		SummonData.CATEGORY.MONSTER:
			scene = load("res://Scenes/summons/monster.tscn")
		SummonData.CATEGORY.DEMON:
			scene = load("res://Scenes/summons/demon.tscn")
	
	target_summoned = scene.instantiate()
	target_summoned.data = load(summons_res[summon_name])
	target_power = target_summoned.data.power
	
	run_sim = true
	state = states.RITUAL_START

func summon() -> void:
	print("fight!")
	smoke_puff.emitting = true
	summoned = target_summoned
	summoned.position = ink_circle.global_position
	summoned.look_at_from_position(ink_circle.global_position, mage.global_position) 
	root.add_child(summoned)
	state = states.GRAPPLE

func add_summon_power(power: int) -> void:
	summon_power += power
	if state == states.RITUAL_START:
		prints("potal_size:", summon_power)
	else:
		prints("summon power:", summon_power)
	if run_sim and summon_power >= target_power \
		and state == states.RITUAL_START:
		summon()
	

func breach(pos: Vector2) -> void:
	run_sim = false
	print("game over", pos)
	massege.show()
	root.process_mode = Node.PROCESS_MODE_DISABLED

func portal_distracted(_pos: Vector2) -> void:
	if summon_power >= target_summoned.data.size:
		state = states.GRAPPLE
		print("portal_done")
	else:
		print("portal distracted")
		clean_texture()

func update_texture() -> void:
	if TextureManager.ink_circle: 
		ink_circle.texture.update(TextureManager.ink_circle)

func clean_texture() -> void:
	run_sim = false
	state = states.RITUAL_READY
	Ink_circle.clean_colors(TextureManager.ink_circle)
	update_texture()

func release_summon() -> void:
	if summoned:
		summoned.queue_free()
		summoned = null
	state = states.RITUAL_READY
	summon_power = 0
	run_sim = false

func kill_summon() -> void:
	if summoned:
		prints("loot: ", summoned.data.loot.pick_random())
	release_summon()

func _on_return_b_pressed() -> void:
	root.process_mode = Node.PROCESS_MODE_INHERIT
	get_tree().reload_current_scene()

func _on_spell_chanted(spell: String) -> void:
	Signals.emit_signal("spell_chanted", spell)
	match spell:
		"zamen verylongshor": init_ritual(SummonData.CATEGORY.ANIMAL, "bull")
		"zamen tzfardio": init_ritual(SummonData.CATEGORY.MONSTER, "ink_toad")
		"zamen mazzik": init_ritual(SummonData.CATEGORY.DEMON, "eye_demon")
		"kill": kill_summon()
		"release": release_summon()
		"clear": clean_texture()
		_: prints("error, unknown spell in", 
		get_tree().get_current_scene())

func _on_book_b_toggled(toggled_on: bool) -> void:
	if SceneManager.current_book != null:
		book_container.visible = toggled_on
