extends Node2D

var points : Array[Vector4] = []
@onready var root: Node2D = $"../.."

func _ready() -> void:
	position = Vector2.ZERO

func _draw():
	for p in points:
		match int(p.w):
			root.tools.INK:
				draw_circle(Vector2(p.x, p.y), p.z,Color.BLACK)
			root.tools.COVER:
				draw_circle(Vector2(p.x, p.y), p.z,Color.WHITE)
func _process(_delta):
	queue_redraw()

func clear() -> void:
	points.clear()
	queue_redraw()

	
