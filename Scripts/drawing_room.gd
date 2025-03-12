extends Node2D

@onready var camera_2d = $Camera2D
@export var cam_speed = 5.0
@export var cam_acceleration = 5.0

@onready var background = $background
var center = Vector2()

var points : Array[Vector2] = []
var texture : Texture2D

var circles : Array[Vector3] = []

var first_point : Vector2 = Vector2.INF
var current_point : Vector2 = Vector2.INF
var snap_distanse : float = 100
var is_mouse_held = false

@export var min_zoom = 0.3
@export var max_zoom = 5.0
@export var zoom_speed = 0.1




func _ready():
	var rect = background.get_rect()
	center = Vector2(background.position.x + (rect.size.x) * 0.5, 
					background.position.y + (rect.size.y) * 0.5)
	camera_2d.position = center
	for i in range(10):
		for j in range(10):
			points.append(Vector2(center.x + (i-5) * 200, center.y + (j-5) * 200))
	
	texture = load("res://Assets/textures/point.png")
	
	queue_redraw()

func _process(delta):
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	camera_2d.position += input_dir * cam_speed
	queue_redraw()

func _draw():
	var scale_factor: float = 0.2
	
	#center
	draw_circle(center, 30.0, Color.RED)
	#dots
	var offset = texture.get_width() * 0.5 * scale_factor
	var original_size = Vector2(texture.get_width(), texture.get_height())
	var scaled_size = original_size * scale_factor
	for p in points:
		draw_texture_rect(texture, Rect2(Vector2(p.x - offset, p.y - offset), scaled_size), false, Color.WHITE)
		
	#mouse position + 
	draw_circle(first_point, 10.0, Color.GREEN_YELLOW)
	draw_circle(current_point, 10.0, Color.GREEN)
	
	#dynamic circle
	if first_point < Vector2.INF:
		var len = (first_point-current_point).length()
		draw_ring(self, first_point, len, 3.0, 16 + len / 20, 0.0, Color.WHITE_SMOKE)
		
	for c in circles:
		draw_ring(self, Vector2(c.x, c.y), c.z, 6.0, 16 + c.z / 20, 0.0, Color.AQUAMARINE)

func _input(event):
	# Track mouse position when it moves
	if event is InputEventMouseMotion:
		current_point = get_global_mouse_position()
		queue_redraw()
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				var mp = get_global_mouse_position()
				#first_point = mp
				var closest_point = find_closest_point(mp, points)
				if closest_point.distance_to(mp) < snap_distanse:
					first_point = closest_point
					is_mouse_held = true
			else:
				var mp = get_global_mouse_position()
				var closest_point = find_closest_point(mp, points)
				if closest_point.distance_to(mp) < snap_distanse and first_point < Vector2.INF:
					circles.append(Vector3(first_point.x, first_point.y, first_point.distance_to(closest_point)))
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

func find_closest_point(target_point: Vector2, point_array: Array[Vector2]) -> Vector2:
	if point_array.size() == 0:
		return Vector2.INF
		
	var closest_point = point_array[0]
	var min_distance = target_point.distance_to(closest_point)
	
	for point in point_array:
		var distance = target_point.distance_to(point)
		if distance < min_distance:
			min_distance = distance
			closest_point = point
	
	return closest_point
