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


# Deletes the user's custom save file from the user:// directory.
func _on_delete_saved_b_pressed() -> void:
	var dir := DirAccess.open("user://")
	if not dir:
		push_error("Failed to open user:// directory for deletion.")
		return

	var file_name: String = SceneManager.SAVE_FILE_PATH.get_file()

	if dir.file_exists(file_name):
		# Delete the file
		var error: Error = dir.remove(file_name)
		if error == OK:
			print("User save file deleted successfully: " + SceneManager.SAVE_FILE_PATH)
		else:
			push_error("Failed to delete save file: " + error_string(error))
	else:
		print("No user save file found to delete.")
	
	Signals.emit_signal("reload_save_file")
