extends Node2D

@onready var camera := $Camera2D
@export var cam_speed: float = 5.0

@onready var background := $background
@onready var chalk_lines: Sprite2D = $chalk_lines

var center := Vector2()
@onready var ink_drawer: Node2D = $SubViewport/ink_drawer
@onready var ink_viewer: Sprite2D = $ink_viewer
@onready var saved_texture: Sprite2D = $SubViewport/saved_texture
@onready var sub_viewport: SubViewport = $SubViewport

@onready var tools_button: Button = $Control/touch_controls/VBoxContainer/tools
@onready var brush_slider: HSlider = $Control/touch_controls/brushSlider

var touch_point : Vector2 = Vector2.INF
@export var item_pin_scene: PackedScene
var item_pin_ghost: Node2D

@export var brush_size : int = 10
@export var max_clear: float = 100

@export var min_zoom:float = 0.5
@export var max_zoom: float = 2.0
@export var zoom_speed: float = 0.05

enum tools{HAND, INK, COVER}
@export_enum("hand", "ink", "cover") var tool: int = 1


func _ready() -> void:
	Signals.connect("spell_chanted", _on_spell_chanted)
	Signals.connect("item_moved", _on_item_moved)
	
	var rect:Rect2 = background.get_rect()
	center = Vector2(background.position.x + (rect.size.x) * 0.5, 
					background.position.y + (rect.size.y) * 0.5)
	camera.position = center
	
	if TextureManager.chalk_line_org:
		chalk_lines.texture = ImageTexture.create_from_image(TextureManager.chalk_line_org)
	
	if TextureManager.ink_circle_org:
		saved_texture.texture = ImageTexture.create_from_image(TextureManager.ink_circle_org)
	
	brush_size = int(brush_slider.value)
	tool = TextureManager.s_tool
	
	for pos: Vector2 in SceneManager.placed_item:
		var item: Item = SceneManager.placed_item[pos]
		add_item_pin(pos * TextureManager.resize_factor, item)
	
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
		camera.position += event.delta
	elif event is InputEventMagnifyGesture:
		camera.zoom = camera.zoom * event.factor
		camera.zoom = camera.zoom.clamp(Vector2(min_zoom, min_zoom), Vector2(max_zoom, max_zoom))
	elif event is InputEventScreenDrag:
		touch_point = get_viewport().get_canvas_transform().affine_inverse() * event.position
		queue_redraw()
		if event.index < 1:
			_handle_touch(touch_point)
	elif event is InputEventScreenTouch and event.is_released():
		touch_point = get_viewport().get_canvas_transform().affine_inverse() * event.position
		queue_redraw()
		if event.index < 1 and tool == tools.HAND and item_pin_ghost:
			add_item_pin(touch_point, item_pin_ghost.item)
			item_pin_ghost.queue_free()

		
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP: # Zoom in
			camera.zoom = camera.zoom * (1 + zoom_speed)
			camera.zoom = camera.zoom.clamp(Vector2(min_zoom, min_zoom), Vector2(max_zoom, max_zoom))
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera.zoom = camera.zoom * (1 - zoom_speed) # Zoom out
			camera.zoom = camera.zoom.clamp(Vector2(min_zoom, min_zoom), Vector2(max_zoom, max_zoom))

func _handle_touch(pos: Vector2) -> void:
		match tool:
			tools.INK:
				ink_drawer.points.append(Vector4(pos.x, pos.y, brush_size, tools.INK))
			tools.COVER:
				ink_drawer.points.append(Vector4(pos.x, pos.y, brush_size, tools.COVER))
			tools.HAND:
				if item_pin_ghost:
					item_pin_ghost.position = pos

func add_item_pin(pos: Vector2, item: Item) -> void:
	var new_item: Node2D = item_pin_scene.instantiate()
	new_item.item = item
	new_item.position = pos
	SceneManager.placed_item[pos / TextureManager.resize_factor] = \
	new_item.item
	#SceneManager.placed_item[pos] = new_item.item
	ink_viewer.add_child(new_item)
	

func clear_circle(pos: Vector2, radius: float) -> void:
	save_to_tex_mem()
	
	TextureManager.ink_circle_org = Ink_circle.mask_circle(TextureManager.ink_circle_org, TextureManager.chalk_line_org, pos, radius)
	sub_viewport.render_target_clear_mode = SubViewport.ClearMode.CLEAR_MODE_ONCE
	ink_drawer.clear()
	get_tree().reload_current_scene()

func save_to_disk() -> void:
	var save_path:String = "res://GameData/ink.png"
	var img : Image = ink_viewer.texture.get_image()
	print("saving... ", img)
	img = Ink_circle.mask_image(img, TextureManager.chalk_line_org)
	img = Ink_circle.resize_image(img, TextureManager.resize_factor)
	img.save_png(save_path)
	
	ink_drawer.clear()

func save_to_tex_mem()  -> void:
	var img : Image = Ink_circle.crop_image_to_circle(ink_viewer.texture.get_image(), 1.0)
	
	img = Ink_circle.mask_image(img, TextureManager.chalk_line_org)
	
	TextureManager.ink_circle_org = img
	TextureManager.ink_circle = Ink_circle.resize_image(img, TextureManager.resize_factor)
	ink_drawer.clear()

func _on_tool_pressed() -> void:
	tool = (tool + 1) % tools.size()
	TextureManager.s_tool = tool
	
	var tool_offset : Array = [0, 450, 905]
	var atlas_icon := tools_button.icon as AtlasTexture
	atlas_icon.region.position.x = tool_offset[tool]

func _on_save_pressed() -> void:
	#save_to_disk()
	save_to_tex_mem()
	reload_scene()

func _on_return_pressed() -> void:
	save_to_tex_mem()
	get_tree().change_scene_to_file("res://Scenes/main_room.tscn")

func _on_move_to_desk_pressed() -> void:
	save_to_tex_mem()
	get_tree().change_scene_to_file("res://Scenes/drawing_desk_2D.tscn")

func _on_clear_pressed() -> void:
	TextureManager.ink_circle_org = null
	TextureManager.ink_circle = null
	reload_scene()

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
		_: printerr("error, unknown spell in ", 
		get_tree().get_current_scene())

func _on_item_moved(item: Item) -> void:
	tool = tools.HAND
	item_pin_ghost = item_pin_scene.instantiate()
	item_pin_ghost.item = item
	item_pin_ghost.position = get_viewport().get_visible_rect().size / 2.0
	add_child(item_pin_ghost)
