extends Control

@export var main_room: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_save_file()
	pass # Replace with function body.

func load_save_file() -> void:
	#TODO: load the save file
	pass

func _on_start_b_pressed() -> void:
	get_tree().change_scene_to_packed(main_room)


func _on_delete_saved_b_pressed() -> void:
	pass # Replace with function body.
