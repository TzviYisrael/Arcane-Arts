extends Sprite2D

@onready var viewport_2: SubViewport = $"../../Viewport2"

func _ready() -> void:
	self.texture = viewport_2.get_texture()
	
func setup(tex: Texture2D) -> void:
	self.texture = tex

func setup_loop() -> void:
	await get_tree().process_frame
	self.texture = viewport_2.get_texture()
	
