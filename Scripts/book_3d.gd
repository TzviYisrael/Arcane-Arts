extends Control

@export var book_scale: Vector3 = Vector3.ONE
@export var book_title: String

@onready var book_3d: SubViewportContainer = $"."
@onready var sub_viewport: SubViewport = $SubViewport

@onready var book_model: Node3D = $SubViewport/Node3D/book_3D
@onready var book_name_label: Label3D = $SubViewport/Node3D/book_3D/book_name_label
@onready var side_name_label: Label3D = $SubViewport/Node3D/book_3D/side_name_label
@onready var button: TextureButton = $Button

var rotation_factor: float
var padding: int = 100

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	book_model.scale = book_scale
	update_rotation(rotation_factor)
	book_name_label.text = book_title
	side_name_label.text = book_title
	
func update_rotation(factor: float) -> void:
	book_model.rotation_degrees.y = lerp(-90, 0, ease(factor, -3))
	var x_size: int = lerp(512, 128, factor) + padding * 2
	book_3d.custom_minimum_size.x = x_size
	button.custom_minimum_size.x = x_size
	sub_viewport.size.x = x_size


func _on_button_pressed() -> void:
	print("pressed!")
