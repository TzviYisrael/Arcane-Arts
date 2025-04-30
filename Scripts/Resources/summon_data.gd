extends Resource
class_name SummonData

@export var hp: int
@export var mp: int
@export var power: int
@export var size: int

@export var model_path: String 
var model: Node3D

enum CATEGORY{ANIMAL, MONSTER, DEMON}
@export_enum ("animal", "monster", "demon") var category: int

func load_model():
	model = load(model_path).instantiate()
	assert(model != null)
