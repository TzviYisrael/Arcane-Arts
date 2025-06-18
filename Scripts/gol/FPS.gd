extends Label

func set_counter() -> void:
	self.set_text("FPS: " + str(Engine.get_frames_per_second()));

func _ready() -> void:
	self.set_counter()

func _physics_process(_delta: float) -> void:
	self.set_counter()
