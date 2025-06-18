extends Sprite2D

@onready var viewport_2: SubViewport = $"../../Viewport2"

func _ready() -> void:
	self.texture = viewport_2.get_texture()
	
func update(tex: Texture2D):
	self.texture = tex
