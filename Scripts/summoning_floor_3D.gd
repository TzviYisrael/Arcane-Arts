extends StaticBody3D

@onready var mage_circle: Sprite3D = $mage_circle
@onready var root: StaticBody3D = $"."

func _ready() -> void:
	pass

func _on_stairs_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			Signals.emit_signal("enter_summon_floor")
