extends Node2D

@onready var camera := $Camera2D
@export var cam_speed: float = 2.0
@export var min_zoom: float = 0.5
@export var max_zoom: float = 2.0
@export var zoom_speed: float = 0.05

@onready var background := $background
var center: Vector2 = Vector2()

@onready var guide_drawer: Node2D = $SubViewport/guide_drawer
@onready var guide_viewer: Sprite2D = $guide_viewer
@onready var saved_texture: Sprite2D = $SubViewport/saved_texture
@onready var sub_viewport: SubViewport = $SubViewport

@onready var tool_button: Button = $Control/touch_controls/VBoxContainer/tool
@onready var debug_label: Label = $Control/touch_controls/debug_label

var points : Array[Vector2] = []
var texture : Texture2D

var circle_guides : Array[Vector4] = []
var line_guides : Array[Vector4] = []

var first_point : Vector2 = Vector2.INF
var current_point : Vector2 = Vector2.INF
const SNAP_DISTANSE : float = 70
var is_finger_held: bool = false

@export var line_thickness : float = 9

enum tools{LINE, CIRCLE}
@export_enum("line", "circle") var tool: int = 0;

func _ready() -> void:
	var rect: Rect2 = background.get_rect()
	center = Vector2(background.position.x + (rect.size.x) * 0.5, 
					background.position.y + (rect.size.y) * 0.5)
	camera.position = center
	for i in range(11):
		for j in range(11):
			points.append(Vector2(center.x + (i-5) * 200, center.y + (j-5) * 200))
	
	texture = load("res://Assets/textures/point.png")
	
	if TextureManager.chalk_line_org:
		saved_texture.texture = ImageTexture.create_from_image(TextureManager.chalk_line_org)
	
	tool_button.text = str(tools.keys()[tool]).to_lower()
	
	queue_redraw()

func _process(_delta: float) -> void:
	#var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	#camera.position += input_dir * cam_speed
	if not is_finger_held:
		current_point = Vector2.INF
	queue_redraw()

func _draw() -> void:
	var dots_scale_factor: float = 0.15
	
	#center
	draw_circle(center, 20.0, Color.RED)
	#dots
	var offset: float = texture.get_width() * 0.5 * dots_scale_factor
	var original_size: Vector2 = Vector2(texture.get_width(), texture.get_height())
	var scaled_size: Vector2 = original_size * dots_scale_factor
	for p in points:
		draw_texture_rect(texture, Rect2(Vector2(p.x - offset, p.y - offset), scaled_size), false, Color.WHITE)
		
	#drawing position
	draw_circle(first_point, 10.0, Color.GREEN_YELLOW)
	draw_circle(current_point, 10.0, Color.GREEN)
	
	#dynamic guides
	if first_point < Vector2.INF:
		match tool:
			tools.CIRCLE:
				var radius: float = (first_point-current_point).length()
				draw_ring(self, first_point, radius, line_thickness / 2, 16 + radius / 20, 0.0, Color.WHITE_SMOKE)
			tools.LINE:
				draw_line(first_point, current_point, Color.WHITE_SMOKE,  line_thickness / 2)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenDrag or event is InputEventScreenTouch:
		current_point = get_viewport().get_canvas_transform().affine_inverse() * event.position
		queue_redraw()
		if event is InputEventScreenTouch and event.index < 1:
			_handle_touch(current_point, event.pressed)
	elif event is InputEventPanGesture:
		camera.position += event.delta
	elif event is InputEventMagnifyGesture:
		camera.zoom = camera.zoom * event.factor
		camera.zoom = camera.zoom.clamp(Vector2(min_zoom, min_zoom), Vector2(max_zoom, max_zoom))
			
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP: # Zoom in
			camera.zoom = camera.zoom * (1 + zoom_speed)
			camera.zoom = camera.zoom.clamp(Vector2(min_zoom, min_zoom), Vector2(max_zoom, max_zoom))
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera.zoom = camera.zoom * (1 - zoom_speed) # Zoom out
			camera.zoom = camera.zoom.clamp(Vector2(min_zoom, min_zoom), Vector2(max_zoom, max_zoom))

func _handle_touch(pos: Vector2, pressed: bool) -> void:
	var closest_point: Vector2 = find_closest_point(pos, points)
	if pressed and not is_finger_held:
		if closest_point.distance_to(pos) < SNAP_DISTANSE:
			first_point = closest_point
			is_finger_held = true
	else: # release
		match tool:
			tools.CIRCLE:
				if closest_point.distance_to(pos) < SNAP_DISTANSE and first_point < Vector2.INF:
					var new_guide := Vector4(first_point.x, first_point.y, first_point.distance_to(closest_point), tools.CIRCLE)
					if not new_guide in guide_drawer.circle_guides:
						guide_drawer.circle_guides.append(new_guide)
			tools.LINE:
				if closest_point.distance_to(pos) < SNAP_DISTANSE and first_point < Vector2.INF:
					var new_guide := Vector4(first_point.x, first_point.y, closest_point.x, closest_point.y)
					if not new_guide in guide_drawer.line_guides:
						guide_drawer.line_guides.append(new_guide)
		first_point = Vector2.INF
		current_point = Vector2.INF
		is_finger_held = false

static func draw_ring(node:CanvasItem, offset:Vector2, radius:float, width:float, resolution:int, rotated:float, color:Color)->void:
	var increments: float = 2*PI / resolution
	var rad: = rotated
	var to: = Vector2.ZERO
	var from: = Vector2(cos(rad)*radius, sin(rad)*radius)
	for i in resolution:
		rad = rotated + increments * (i+1)
		to = Vector2(cos(rad)*radius, sin(rad)*radius)
		node.draw_line(offset + from, offset + to, color, width)
		from = to

## Draw an infinite line from a point with an angle
func draw_infinite_line(point: Vector2, angle_rad: float, width: float, color: Color = Color.WHITE) -> void:
	# Get viewport size for calculating line length
	var viewport_size: Vector2 = get_viewport_rect().size
	var max_length := viewport_size.length() * 2 
	
	# Calculate end points using cos/sin
	var direction := Vector2(cos(angle_rad), sin(angle_rad))
	var start_point: Vector2 = point - direction * max_length
	var end_point: Vector2 = point + direction * max_length
	
	# Draw the line
	draw_line(start_point, end_point, color, width)

func find_closest_point(target_point: Vector2, point_array: Array[Vector2]) -> Vector2:
	if point_array.size() == 0:
		return Vector2.INF
		
	var closest_point: Vector2 = point_array[0]
	var min_distance: float = target_point.distance_to(closest_point)
	
	for point in point_array:
		var distance: float = target_point.distance_to(point)
		if distance < min_distance:
			min_distance = distance
			closest_point = point
	
	return closest_point

func save_to_disk() -> void:
	var save_path: String = "res://GameData/chalk.png"
	var img : Image = guide_viewer.texture.get_image()
	print("saving... ", img)
	img.save_png(save_path)
	
	guide_drawer.clear()

func save_to_tex_men() -> void:
	var img : Image = Ink_circle.crop_image_to_circle(guide_viewer.texture.get_image(), 1.0)
	TextureManager.chalk_line_org = img
	TextureManager.chalk_line = Ink_circle.resize_image(img, TextureManager.resize_factor)
	guide_drawer.clear()

func _on_tool_pressed() -> void:
	tool = (tool + 1) % tools.size()
	tool_button.text = str(tools.keys()[tool]).to_lower()

func _on_save_pressed() -> void:
	save_to_tex_men()
	
func _on_return_pressed() -> void:
	save_to_tex_men()
	get_tree().change_scene_to_file("res://Scenes/main_room.tscn")

func _on_move_to_floor_pressed() -> void:
	save_to_tex_men()
	get_tree().change_scene_to_file("res://Scenes/summoning_floor_2D.tscn")

func reset() -> void:
	TextureManager.chalk_line_org = null
	TextureManager.chalk_line = null
	sub_viewport.render_target_clear_mode = SubViewport.ClearMode.CLEAR_MODE_ONCE
	guide_drawer.clear()
	get_tree().reload_current_scene()

func _on_spell_chanted(spell: String) -> void:
	match spell:
		"reset": reset()
		_: prints("error, unknown spell in", 
		get_tree().get_current_scene())
