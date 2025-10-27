extends Resource
class_name SummonData

@export var name: String
@export var hp: int
@export var mp: int
@export var power: int
@export var size: int
@export var loot: Array
@export var colors_rec: Dictionary[Color, int]

@export var model: PackedScene
@export var model_scale: float

enum CATEGORY{ANIMAL, MONSTER, DEMON}
@export_enum ("animal", "monster", "demon") var category: int
