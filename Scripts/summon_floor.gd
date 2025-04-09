extends Node2D

@onready var camera_2d = $Camera2D
@export var cam_speed = 5.0
@export var cam_acceleration = 5.0

@onready var background = $background
@onready var chalk_lines: Sprite2D = $chalk_lines

var center = Vector2()
@onready var ink_drawer: Node2D = $SubViewport/ink_drawer
@onready var ink_viewer: Sprite2D = $ink_viewer
@onready var saved_texture: Sprite2D = $SubViewport/saved_texture
@onready var sub_viewport: SubViewport = $SubViewport

@onready var tool_button: Button = $Control/touch_controls/VBoxContainer/tool
@onready var brush_slider: HSlider = $Control/touch_controls/brushSlider

var first_point : Vector2 = Vector2.INF
var current_point : Vector2 = Vector2.INF
const SNAP_DISTANSE : float = 50
var is_mouse_held = false

@export var brush_size : int = 10
@export var max_clear: float = 100

@export var min_zoom = 0.5
@export var max_zoom = 2.0
@export var zoom_speed = 0.05

enum tools{INK, COVER}
@export_enum("ink", "cover", "clear") var tool: int = 0;


func _ready():
	var rect = background.get_rect()
	center = Vector2(background.position.x + (rect.size.x) * 0.5, 
					background.position.y + (rect.size.y) * 0.5)
	camera_2d.position = center
	
	if TextureManager.chalk_line_org:
		chalk_lines.texture = ImageTexture.create_from_image(TextureManager.chalk_line_org)
	
	if TextureManager.ink_circle_org:
		saved_texture.texture = ImageTexture.create_from_image(TextureManager.ink_circle_org)
	
	brush_size = int(brush_slider.value)
	tool = TextureManager.s_tool
	tool_button.text = str(tools.keys()[tool]).to_lower()
	
	
	queue_redraw()

func _process(_delta):
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	camera_2d.position += input_dir * cam_speed
	
	if is_mouse_held:
		var mp = get_global_mouse_position()
		match tool:
			tools.INK:
				ink_drawer.points.append(Vector4(mp.x, mp.y, brush_size, tools.INK))
			tools.COVER:
				ink_drawer.points.append(Vector4(mp.x, mp.y, brush_size, tools.COVER))
	
	queue_redraw()

func _draw():
	#center
	draw_circle(center, 30.0, Color.RED)
	
	#mouse position
	draw_circle(current_point, brush_size,Color.GREEN if tool == tools.INK else Color.WHITE, false, 3.0)
	
	#if tool == tools.CLEAR and is_mouse_held:
		#draw_circle(first_point, min(first_point.distance_to(current_point), max_clear), Color.AQUAMARINE, true)

func _unhandled_input(event: InputEvent) -> void:
	
	if is_mouse_held:
		var mp = get_global_mouse_position()
		match tool:
			tools.INK:
				ink_drawer.points.append(Vector4(mp.x, mp.y, brush_size, tools.INK))
			tools.COVER:
				ink_drawer.points.append(Vector4(mp.x, mp.y, brush_size, tools.COVER))				
	# Track mouse position when it moves
	if event is InputEventMouseMotion:
		current_point = get_global_mouse_position()
		queue_redraw()
	
	if event is InputEventMouseButton:
		
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				first_point = current_point
				is_mouse_held = true
			else: #release LMB
				#if tool == tools.CLEAR:
					#clear_circle(first_point, min(first_point.distance_to(current_point), max_clear))
				first_point = Vector2.INF
				is_mouse_held = false
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			# Zoom in
			camera_2d.zoom = camera_2d.zoom * (1 + zoom_speed)
			camera_2d.zoom = camera_2d.zoom.clamp(Vector2(min_zoom, min_zoom), Vector2(max_zoom, max_zoom))
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			# Zoom out
			camera_2d.zoom = camera_2d.zoom * (1 - zoom_speed)
			camera_2d.zoom = camera_2d.zoom.clamp(Vector2(min_zoom, min_zoom), Vector2(max_zoom, max_zoom))

func clear_circle(pos: Vector2, radius: float) -> void:
	save_to_tex_men()
	
	TextureManager.ink_circle_org = Ink_circle.mask_circle(TextureManager.ink_circle_org, TextureManager.chalk_line_org, pos, radius)
	sub_viewport.render_target_clear_mode = SubViewport.ClearMode.CLEAR_MODE_ONCE
	ink_drawer.clear()
	get_tree().reload_current_scene()

func save_to_disk():
	var save_path = "res://GameData/ink.png"
	var img : Image = ink_viewer.texture.get_image()
	print("saving... ", img)
	img = Ink_circle.mask_image(img, TextureManager.chalk_line_org)
	img = Ink_circle.resize_image(img, TextureManager.resize_factor)
	img.save_png(save_path)
	
	ink_drawer.clear()

func save_to_tex_men():
	var img : Image = Ink_circle.crop_image_to_circle(ink_viewer.texture.get_image(), 1.0)
	
	img = Ink_circle.mask_image(img, TextureManager.chalk_line_org)
	
	TextureManager.ink_circle_org = img
	TextureManager.ink_circle = Ink_circle.resize_image(img, TextureManager.resize_factor)
	ink_drawer.clear()

func _on_tool_pressed() -> void:
	tool = (tool + 1) % tools.size()
	TextureManager.s_tool = tool
	tool_button.text = str(tools.keys()[tool]).to_lower()

func _on_save_pressed() -> void:
	#save_to_disk()
	save_to_tex_men()
	reload_scene()

func _on_return_pressed() -> void:
	save_to_tex_men()
	get_tree().change_scene_to_file("res://Scenes/main_room.tscn")

func _on_move_to_desk_pressed() -> void:
	save_to_tex_men()
	get_tree().change_scene_to_file("res://Scenes/drawing_desk.tscn")

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
