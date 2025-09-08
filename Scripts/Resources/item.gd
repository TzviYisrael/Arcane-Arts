extends Resource
class_name Item

@export var name: String
enum {NATURAL, MYSTIC, DEMONIC}
@export_enum("natural", "mystic", "demonic") var origin: int = 0
@export var icon: Texture2D
@export var color: Color
@export var model: PackedScene
