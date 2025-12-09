extends TextureRect

@onready var circle_diagram: TextureRect = $"."
@onready var sub_viewport: SubViewport = $SubViewport
@onready var drawer: Node2D = $SubViewport/drawer

@export var lines_strings: Array = []
@export var circles_strings: Array = []
@export var dots_strings: Array = []
@export var symbols_strings: Array = []
@export var image_size := Vector2(400, 400)
@export var lines_color: Color = Color.BLACK
@export var lines_thickness: float = 2.0
@export var base_texture: Texture2D 

func _ready() -> void:
	pass

func bake_drawing_to_texture() -> void:
	sub_viewport.size = image_size
	
	drawer = DrawingLayer.new()
	drawer.lines_strings = lines_strings
	drawer.circles_strings = circles_strings
	drawer.dots_strings = dots_strings
	drawer.symbols_strings = symbols_strings
	drawer.center_point = sub_viewport.size / 2
	drawer.symbol_font = get_theme_default_font()
	drawer.lines_color = lines_color
	drawer.lines_thickness = lines_thickness
	drawer.background_texture = base_texture
	
	sub_viewport.add_child(drawer)
	
	await RenderingServer.frame_post_draw
	
	var img: Image = sub_viewport.get_texture().get_image()
	self.texture = ImageTexture.create_from_image(img)


class DrawingLayer extends Node2D:
	
	var lines_strings: Array
	var circles_strings: Array
	var dots_strings: Array
	var symbols_strings: Array
	var center_point: Vector2
	var symbol_font: Font
	var lines_color: Color
	var lines_thickness: float
	var background_texture: Texture2D

	func _draw() -> void:
		if background_texture:
			draw_texture(background_texture, Vector2.ZERO)

		# Draw all elements
		for line: String in lines_strings:
			draw_line_from_string(line)
		for circle: String in circles_strings:
			draw_ring_from_string(circle)
		for dot: String in dots_strings:
			draw_dot_from_string(dot)
		for symbol: String in symbols_strings:
			draw_symbol_from_string(symbol)
	
	# --- Utility Function ---
	
	# Converts a raw comma-separated string (e.g., "10,0,10,-5,1") into an Array of floats.
	static func _parse_coords(string: String) -> Array[float]:
		var coords: Array[float] = []
		var parts: PackedStringArray = string.split(",", false)
		
		for part: String in parts:
			var val: String = part.strip_edges()
			# Only convert to float if it's a valid number. Skip non-numeric parts.
			if val.is_valid_float():
				coords.append(float(val))
		return coords


	# --- Drawing Implementations ---
	
	# Format: "x1,y1,x2,y2"
	func draw_line_from_string(string: String) -> void:
		var coords: Array[float] = _parse_coords(string)
		if coords.size() < 4: return
		
		var p1: Vector2 = center_point + Vector2(coords[0], coords[1])
		var p2: Vector2 = center_point + Vector2(coords[2], coords[3])
		draw_line(p1, p2, lines_color, lines_thickness, true)

	# Format: "center_x,center_y,radius" (Empty Circle / Ring)
	func draw_ring_from_string(string: String) -> void:
		var coords: Array[float] = _parse_coords(string)
		if coords.size() < 3: return
		
		var center: Vector2 = center_point + Vector2(coords[0], coords[1])
		var radius: float = coords[2]
		
		# Use the provided static helper function to draw the ring
		draw_ring(self, center, radius, lines_thickness, 64, 0.0, lines_color)
		
	# Format: "center_x,center_y,radius,color_hex" (Filled Dot)
	func draw_dot_from_string(string: String) -> void:
		var parts: PackedStringArray = string.split(",", false)
		
		# Check for minimum parts: X, Y, Radius, Color
		if parts.size() < 4: return
		
		# Color is the last element
		var color_str: String = Array(parts).back().strip_edges()
		var dot_color: Color = Color(color_str)
		
		# Coords are the first three elements (X, Y, Radius)
		var coords_str: String = string.substr(0, string.rfind(","))
		var coords: Array[float] = _parse_coords(coords_str)
		
		if coords.size() < 3: return
		
		var center: Vector2 = center_point + Vector2(coords[0], coords[1])
		var radius: float = coords[2]
		
		# Dot is a filled circle
		draw_circle(center, radius, dot_color)
		
	# Format: "center_x,center_y,symbol_text,size,color_hex"
	func draw_symbol_from_string(string: String) -> void:
		var parts: PackedStringArray = string.split(",", false)
		# Check for minimum parts: X, Y, Symbol, Size, Color
		if parts.size() < 5: return
		
		# Color is the last element
		var color_str: String = Array(parts).back().strip_edges()
		var symbol_color: Color = Color(color_str)

		# Size is the second-to-last element
		var font_size_float := float(parts[parts.size() - 2].strip_edges())
		var font_size: int = int(font_size_float)
		
		# Symbol text (The third-to-last element)
		var symbol_char: String = parts[parts.size() - 3].strip_edges()
		
		# Y Coordinate (The fourth-to-last element)
		var y_coord: float = float(parts[parts.size() - 4].strip_edges())
		
		# X Coordinate (The fifth-to-last element / The first element)
		var x_coord: float = float(parts[0].strip_edges())
		
		# Assemble the center point
		var center: Vector2 = center_point + Vector2(x_coord, y_coord)
		
		# Set alignment to center the symbol on the point
		var align_center: float = -symbol_font.get_string_size(symbol_char, font_size).x / 2.0
		var align_baseline: float = symbol_font.get_ascent(font_size) / 2.0
		
		draw_string(symbol_font, center + Vector2(align_center, align_baseline), 
					symbol_char, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, symbol_color)

	# ... (Static draw_ring function remains the same)
	static func draw_ring(node:CanvasItem, offset:Vector2, radius:float, width:float, resolution:int, 
	rotated:float, color:Color) -> void:
		var increments: float = 2*PI / resolution
		var rad: = rotated
		var to: = Vector2.ZERO
		var from: = Vector2(cos(rad)*radius, sin(rad)*radius)
		for i in resolution:
			rad = rotated + increments * (i+1)
			to = Vector2(cos(rad)*radius, sin(rad)*radius)
			node.draw_line(offset + from, offset + to, color, width, true)
			from = to
