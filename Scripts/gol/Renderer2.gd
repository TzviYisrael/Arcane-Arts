extends Sprite2D

@onready var viewport: SubViewport = $"../../Viewport"

func _ready() -> void:
	self.texture = viewport.get_texture()
