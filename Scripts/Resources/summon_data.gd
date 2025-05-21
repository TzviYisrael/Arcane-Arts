extends Resource
class_name SummonData

@export var hp: int
@export var mp: int
@export var power: int
@export var size: int
@export var loot: Array[String]

@export var model_path: String 
var model: Node3D
@export var model_scale: float

enum CATEGORY{ANIMAL, MONSTER, DEMON}
@export_enum ("animal", "monster", "demon") var category: int

func load_model() -> void:
	model = load(model_path).instantiate()
	model.scale = Vector3(model_scale, model_scale, model_scale)
	assert(model != null)
