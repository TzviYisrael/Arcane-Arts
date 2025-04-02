extends StaticBody3D

@onready var decal: Decal = $Decal
@onready var mage_circle: Sprite3D = $mage_circle
@onready var root: StaticBody3D = $"."

func _ready() -> void:
	
	if TextureManager.ink_circle:
		var ink = ImageTexture.create_from_image(TextureManager.ink_circle)
		decal.texture_albedo = ink
		decal.texture_normal = ink
	else:
		decal.texture_albedo = null
		decal.texture_normal = null
		
func _process(delta: float) -> void:
	pass #decal.rotation.y += deg_to_rad(1)

func _on_stairs_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			Signals.emit_signal("enter_summon_floor")
