extends Sprite2D

@export var viewport: SubViewport

func _ready() -> void:
	self.texture = viewport.get_texture()

func setup(tex: Texture2D) -> void:
	self.texture = tex

func setup_loop() -> void:
	await get_tree().process_frame
	self.texture = viewport.get_texture()
