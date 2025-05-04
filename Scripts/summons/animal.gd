extends CharacterBody3D

@export var data: SummonData

var mage: Node
func _ready() -> void:
	data.load_model()
	add_child(data.model)
	mage = SceneManager.mage
	data.model.rotate_y(PI)
