extends Control

@export var rotation_factor: float
@export var book_title: String

@onready var book_3d: SubViewportContainer = $"."
@onready var sub_viewport: SubViewport = $SubViewport

@onready var csg_mesh_3d: CSGMesh3D = $SubViewport/Node3D/CSGMesh3D
@onready var label_3d: Label3D = $SubViewport/Node3D/CSGMesh3D/Label3D
@onready var label_3d_2: Label3D = $SubViewport/Node3D/CSGMesh3D/Label3D2


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_rotation(rotation_factor)
	label_3d.text = book_title
	label_3d_2.text = book_title
	
func update_rotation(factor: float) -> void:
	csg_mesh_3d.rotation_degrees.y = lerp(-180, -90, factor)
	var x_size: int = lerp(512, 128, factor)
	book_3d.custom_minimum_size.x = x_size
	sub_viewport.size.x = x_size
