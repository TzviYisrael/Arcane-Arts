extends CharacterBody3D

@export var data: SummonData

var mage: Node
func _ready() -> void:
	load_model()
	mage = SceneManager.mage

func load_model() -> void:
	var model := data.model.instantiate()
	model.scale = Vector3(data.model_scale, data.model_scale, data.model_scale)
	model.rotate_y(PI)
	add_child(model)
	assert(model != null)
