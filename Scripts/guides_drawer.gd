extends Node2D

var circle_guides : Array[Vector4] = []
var line_guides : Array[Vector4] = []
@onready var root: Node2D = $"../.."

func _ready() -> void:
	position = Vector2.ZERO

func _draw():
	for c in circle_guides:
			draw_ring(self, Vector2(c.x, c.y), c.z, root.line_thickness, int(16.0 + c.z / 20.0), 0.0, Color.WHEAT)
		
	for l in line_guides:
		draw_line(Vector2(l.x, l.y), Vector2(l.z, l.w), Color.WHEAT, root.line_thickness)


func _process(_delta):
	queue_redraw()


static func draw_ring(node:CanvasItem, offset:Vector2, radius:float, width:float, resolution:int, rotated:float, color:Color)->void:
	var increments: float = 2*PI / resolution
	var rad: = rotated
	var to: = Vector2.ZERO
	var from: = Vector2(cos(rad)*radius, sin(rad)*radius)
	for i in resolution:
		rad = rotated + increments * (i+1)
		to = Vector2(cos(rad)*radius, sin(rad)*radius)
		node.draw_line(offset + from, offset + to, color, width, true)
		from = to

# Draw an infinite line from a point with an angle
func draw_infinite_line(point: Vector2, angle_rad: float, width: float, color: Color = Color.WHITE) -> void:
	# Get viewport size for calculating line length
	var viewport_size = get_viewport_rect().size
	var max_length = viewport_size.length() * 2  # Make it longer than the diagonal
	
	# Calculate end points using cos/sin
	var direction = Vector2(cos(angle_rad), sin(angle_rad))
	var start_point = point - direction * max_length
	var end_point = point + direction * max_length
	
	draw_line(start_point, end_point, color, width, true)

func clear() -> void:
	circle_guides.clear()
	line_guides.clear()
	queue_redraw()

	
