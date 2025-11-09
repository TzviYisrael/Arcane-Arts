extends Node2D

@onready var camera := $Camera2D
@export var cam_speed: float = 4.0
@export var min_zoom:float = 0.3
@export var max_zoom: float = 2.0
@export var zoom_speed: float = 0.05

@onready var background := $Parallax2D/MainRoomFloor
@onready var chalk_lines: Sprite2D = $chalk_lines

var center := Vector2()
@onready var ink_drawer: Node2D = $SubViewport/ink_drawer
@onready var ink_viewer: Sprite2D = $ink_viewer
@onready var saved_texture: Sprite2D = $SubViewport/saved_texture
@onready var sub_viewport: SubViewport = $SubViewport

@onready var Renderer := $Viewport/Renderer
@onready var Renderer2: Sprite2D = $Viewport2/Renderer2

@onready var tools_button: Button = $Control/touch_controls/VBoxContainer/tools
@onready var brush_slider: HSlider = $Control/touch_controls/brushSlider

var touch_point : Vector2 = Vector2.INF
@export var item_pin_scene: PackedScene
var item_pin_ghost: Node2D

@export var brush_size : int = 10
@export var max_clear: float = 100

enum tools{HAND, INK, COVER}
@export_enum("hand", "ink", "cover") var tool: int = 1


func _ready() -> void:
	Signals.connect("spell_chanted", _on_spell_chanted)
	Signals.connect("item_moved", _on_item_moved)
	
	$Viewport.set_update_mode(SubViewport.UPDATE_ALWAYS)
	$Viewport2.set_update_mode(SubViewport.UPDATE_ALWAYS)

	if not Renderer:
		print("Could not mount renderer")
		return
	
	camera.position = Vector2.ZERO
	
	if TextureManager.chalk_line_2d:
		chalk_lines.texture = ImageTexture.create_from_image(TextureManager.chalk_line_2d)
		Renderer.material.set_shader_parameter("chalk_lines", chalk_lines.texture)
		Renderer.material.set_shader_parameter("is_chalk", true)

	if TextureManager.ink_circle_2d:
		saved_texture.texture = ImageTexture.create_from_image(TextureManager.ink_circle_2d)
	
	
	brush_size = int(brush_slider.value)
	tool = SceneManager.summoning_floor_current_tool
	set_tool_icon()
	
	call_deferred("add_initial_pins")
		
	queue_redraw()

func _process(_delta: float)  -> void:
	var input_dir: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	camera.position += input_dir * cam_speed
	queue_redraw()

func _draw()  -> void:
	#center
	draw_circle(center, 20.0, Color.RED)
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventPanGesture:
		_handle_pan(event.delta)
	elif event is InputEventMagnifyGesture:
		_handle_zoom(event.factor)
		
	elif event is InputEventScreenDrag:
		touch_point = get_viewport().get_canvas_transform().affine_inverse() * event.position + Vector2(1012, 1012)
		queue_redraw()
		if event.index < 1:
			_handle_touch(touch_point)
	elif event is InputEventScreenTouch and event.is_released():
		touch_point = get_viewport().get_canvas_transform().affine_inverse() * event.position + Vector2(1012, 1012)
		queue_redraw()
		if event.index < 1 and tool == tools.HAND and item_pin_ghost:
			if add_item_pin(touch_point - Vector2(1012, 1012), item_pin_ghost.item):
				item_pin_ghost.queue_free()
			else:
				item_pin_ghost.position = camera.get_screen_center_position()
			
			tool = SceneManager.summoning_floor_current_tool
			var tool_offset : Array = [0, 450, 905]
			var atlas_icon := tools_button.icon as AtlasTexture
			atlas_icon.region.position.x = tool_offset[tool]

	#for debug only
	elif event is InputEventMouseButton:
		var factor := 1.0
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			factor = (1.0 + zoom_speed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			factor = (1.0 - zoom_speed)

		if factor != 1.0:
			_handle_zoom(factor)

func _handle_zoom(zoom_factor: float) -> void:
	camera.zoom *= zoom_factor
	camera.zoom = camera.zoom.clamp(Vector2(min_zoom, min_zoom), Vector2(max_zoom, max_zoom))
	get_viewport().set_input_as_handled()

func _handle_pan(delta: Vector2) -> void:
	var current_zoom_factor: float  = camera.zoom.x
	var adjusted_speed: float = cam_speed / current_zoom_factor
	camera.position += delta * adjusted_speed
	get_viewport().set_input_as_handled()

func _handle_touch(pos: Vector2) -> void:
		match tool:
			tools.INK:
				#print( pos / Vector2(2024, 2024))
				Renderer.material.set_shader_parameter("brush_pos", pos / Vector2(2024, 2024))
				ink_drawer.points.append(Vector4(pos.x, pos.y, brush_size, tools.INK))
			tools.COVER:
				ink_drawer.points.append(Vector4(pos.x, pos.y, brush_size, tools.COVER))
			tools.HAND:
				if item_pin_ghost:
					item_pin_ghost.position = pos - Vector2(1012, 1012)

func add_initial_pins() -> void:
	for pos: Vector2 in SceneManager.placed_item:
		var item: Item = SceneManager.placed_item[pos]
		var half_size: Vector2 = ink_viewer.texture.get_size() * 0.5
		var denormalized_pos := pos * half_size
		add_item_pin(denormalized_pos, item)


func add_item_pin(pos: Vector2, item: Item) -> bool:
	var half_size: Vector2 = ink_viewer.texture.get_size() * 0.5
	if not (-half_size.x <= pos.x and pos.x < half_size.x and -half_size.y <= pos.y and pos.y < half_size.y):
		print("Trying to add pin outside the zone: ", pos)
		return false
	
	var new_item: Node2D = item_pin_scene.instantiate()
	new_item.item = item
	new_item.position = pos
	new_item.add_to_group("items")
	
	# Normalize positions from -half_size <-> half_size to -1 <-> 1
	var normalized_pos: Vector2 = pos / half_size
	SceneManager.placed_item[normalized_pos] = new_item.item
	
	ink_viewer.add_child(new_item)
	return true

func set_tool_icon() -> void:
	var tool_offset : Array = [0, 450, 905]
	var atlas_icon := tools_button.icon as AtlasTexture
	atlas_icon.region.position.x = tool_offset[tool]

func clear_circle(pos: Vector2, radius: float) -> void:
	save_to_tex_mem()
	
	TextureManager.ink_circle_2d = Ink_circle.mask_circle(TextureManager.ink_circle_2d, TextureManager.chalk_line_2d, pos, radius)
	sub_viewport.render_target_clear_mode = SubViewport.ClearMode.CLEAR_MODE_ONCE
	ink_drawer.clear()
	get_tree().reload_current_scene()

func save_to_disk() -> void:
	var save_path:String = "res://GameData/ink.png"
	var img : Image = ink_viewer.texture.get_image()
	print("saving... ", img)
	img = Ink_circle.mask_image(img, TextureManager.chalk_line_2d)
	img = Ink_circle.resize_image(img, TextureManager.resize_factor)
	img.save_png(save_path)
	
	ink_drawer.clear()

func save_to_tex_mem()  -> void:
	var img : Image = Ink_circle.crop_image_to_circle(ink_viewer.texture.get_image(), 1.0)
	
	img = Ink_circle.mask_image(img, TextureManager.chalk_line_2d)
	
	TextureManager.ink_circle_2d = img
	TextureManager.ink_circle = Ink_circle.resize_image(img, TextureManager.resize_factor)
	ink_drawer.clear()

func _on_tool_pressed() -> void:
	tool = (tool + 1) % tools.size()
	SceneManager.summoning_floor_current_tool = tool
	set_tool_icon()

func _on_save_pressed() -> void:
	#save_to_disk()
	save_to_tex_mem()
	reload_scene()

func _on_return_pressed() -> void:
	save_and_change_scene("res://Scenes/main_room.tscn")

func _on_move_to_desk_pressed() -> void:
	save_and_change_scene("res://Scenes/drawing_desk_2D.tscn")

func _on_clear_pressed() -> void:
	TextureManager.ink_circle_2d = null
	TextureManager.ink_circle = null
	reload_scene()

func _on_clear_pins_pressed() -> void:
	for item in ink_viewer.get_children():
		if item.is_in_group("items"):
			item.queue_free()
	SceneManager.placed_item.clear()

func reload_scene() -> void:
	sub_viewport.render_target_clear_mode = SubViewport.ClearMode.CLEAR_MODE_ONCE
	ink_drawer.clear()
	get_tree().reload_current_scene()

func _on_show_guides_pressed() -> void:
	if chalk_lines.visible:
		chalk_lines.hide()
	else:
		chalk_lines.show()

func _on_h_slider_value_changed(value: float) -> void:
	brush_size = int(value)

func _on_spell_chanted(spell: String) -> void:
	match spell:
		"reset": _on_clear_pressed()
		"save": _on_save_pressed()
		"clear pins": _on_clear_pins_pressed()
		_: printerr("error, unknown spell in ", 
		get_tree().get_current_scene())

func _on_item_moved(item: Item) -> void:
	tool = tools.HAND
	var atlas_icon := tools_button.icon as AtlasTexture
	atlas_icon.region.position.x = 0
	
	item_pin_ghost = item_pin_scene.instantiate()
	item_pin_ghost.item = item
	item_pin_ghost.position = camera.get_screen_center_position()
	add_child(item_pin_ghost)

func save_and_change_scene(scene_path: String) -> void:
	save_to_tex_mem()
	
	SceneManager.summoning_floor_current_tool = tool
	get_tree().change_scene_to_file(scene_path)
