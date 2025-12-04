extends Node

# Define the save file path, now pointing to a resource file
const SAVE_FILE_PATH: String = "user://savegame.res"

# --- Global & Dynamic Data ---

# Global
var inventory: Dictionary[String, int] = {}

# Mage
var camera_rot_deg := Vector3(-30.0, 0.0, 0.0)

# Main Room
var mage: Node # Node reference is not saved
var mage_pos := Vector3(10, 0.192, -5)
var mage_rot := Vector3(0.0, 0.0, 0.0)

# placed_item stores Vector2 keys and Item objects
var placed_item: Dictionary[Vector2, Item] = {}

# Drawing Desk
var drawing_desk_current_tool: int = 1

# Summoning Floor
var summoning_floor_brush_size: float = 0.29
var summoning_floor_current_tool: int = 1

# UI
enum {MAIN, SUMMON_FLOOR, DRAWING_DESK}
var current_room: int = MAIN
var current_book: BookContent

# --- Texture Manager (Dynamic Images) ---

var chalk_line: Image
var ink_circle: Image
var chalk_line_2d: Image
var ink_circle_2d: Image

const resize_factor: int = 4

## Resizes an image by the given factor using Lanczos interpolation.
func resize_image(image: Image, factor: int) -> Image:
	var new_image := image.duplicate()
	var new_width := image.get_width() / float(factor)
	var new_height := image.get_height() / float(factor)
	new_image.resize(new_width, new_height, Image.INTERPOLATE_LANCZOS)
	return new_image

func set_mage(mage_node: Node) -> void:
	mage = mage_node

# --- Utility Functions for Image Serialization ---

## Converts an Image object to a PackedByteArray (PNG format) for saving.
func _image_to_byte_array(image: Image) -> PackedByteArray:
	if not is_instance_valid(image) or image.is_empty():
		return PackedByteArray()
	var bytes := PackedByteArray()
	# Save as PNG buffer for compression and reliability
	bytes = image.save_png_to_buffer()
	return bytes

## Converts a PackedByteArray back to an Image object.
func _byte_array_to_image(bytes: PackedByteArray) -> Image:
	if bytes.is_empty():
		return null
	var image := Image.new()
	# Load from the PNG buffer
	var error: Error = image.load_png_from_buffer(bytes)
	if error != OK:
		push_error("Failed to load image from bytes: " + error_string(error))
		return null
	return image

# --- Save and Load Functions (Using SaveData Resource) ---

## Saves the game state to the SaveData resource file.
func save_game() -> Error:
	## Use ResourceLoader to get the script, then instantiate it
	#var SaveDataScript = load("res://SaveData.gd")
	#if SaveDataScript == null:
		#push_error("SaveData.gd script not found. Make sure it's in the project root.")
		#return ERR_CANT_OPEN

	var save_data: SaveData = SaveData.new()

	# 1. Copy state from SceneManager to Resource
	save_data.inventory = inventory
	save_data.camera_rot_deg = camera_rot_deg
	save_data.mage_pos = mage_pos
	save_data.mage_rot = mage_rot

	# Convert placed_item dictionary into serializable array of dicts
	var placed_item_array: Array[Dictionary] = []
	for pos in placed_item:
		placed_item_array.append({
			"pos": pos,
			"item_name": placed_item[pos].name
		})
	save_data.placed_item_data = placed_item_array

	save_data.drawing_desk_current_tool = drawing_desk_current_tool
	save_data.summoning_floor_brush_size = summoning_floor_brush_size
	save_data.summoning_floor_current_tool = summoning_floor_current_tool
	save_data.current_room = current_room
	
	# Save the book's path/ID
	if current_book is Resource:
		save_data.current_book_id = current_book.resource_path
	else:
		save_data.current_book_id = ""

	# Serialize Images to ByteArrays for saving
	save_data.chalk_line_data = _image_to_byte_array(chalk_line)
	save_data.ink_circle_data = _image_to_byte_array(ink_circle)
	save_data.chalk_line_2d_data = _image_to_byte_array(chalk_line_2d)
	save_data.ink_circle_2d_data = _image_to_byte_array(ink_circle_2d)

	# 2. Save the resource to disk
	var error: Error = ResourceSaver.save(save_data, SAVE_FILE_PATH)
	if error != OK:
		push_error("Failed to save game resource: " + error_string(error))
	else:
		print("Game saved successfully to: " + SAVE_FILE_PATH)
	return error

## Loads game data from the SaveData resource file and restores state.
func load_game() -> Error:
	if not ResourceLoader.exists(SAVE_FILE_PATH):
		print("No save file found at: " + SAVE_FILE_PATH)
		return ERR_FILE_NOT_FOUND

	# 1. Load the resource
	var save_data: SaveData = ResourceLoader.load(SAVE_FILE_PATH) as SaveData
	if not save_data:
		push_error("Failed to load save data resource.")
		return ERR_CANT_OPEN

	# 2. Copy state from Resource back to SceneManager
	
	# Global
	inventory = save_data.inventory

	# Mage
	camera_rot_deg = save_data.camera_rot_deg

	# Main Room
	mage_pos = save_data.mage_pos
	mage_rot = save_data.mage_rot

	# Restore placed_item
	placed_item.clear()
	for item_data in save_data.placed_item_data:
		var pos: Vector2 = item_data.get("pos")
		var item_name: String = item_data.get("item_name")
		
		if pos is Vector2 and item_name is String:
			placed_item[pos] = GameData[item_name]

	# Drawing Desk
	drawing_desk_current_tool = save_data.drawing_desk_current_tool

	# Summoning Floor
	summoning_floor_brush_size = save_data.summoning_floor_brush_size
	summoning_floor_current_tool = save_data.summoning_floor_current_tool

	# UI
	current_room = save_data.current_room

	# Restore current_book (requires resource loading logic)
	#var book_id = save_data.current_book_id
	#if book_id != "":
		## Example: current_book = load(book_id)
		#pass # Implement your specific resource loading here

	# Deserialize Images from ByteArrays
	chalk_line = _byte_array_to_image(save_data.chalk_line_data)
	ink_circle = _byte_array_to_image(save_data.ink_circle_data)
	chalk_line_2d = _byte_array_to_image(save_data.chalk_line_2d_data)
	ink_circle_2d = _byte_array_to_image(save_data.ink_circle_2d_data)
	
	# It's good practice to free resources that are only temporarily loaded
	save_data.free()
		
	print("Game loaded successfully.")
	return OK

# --- Game Lifecycle Hooks ---

func _ready() -> void:
	Signals.connect("save_game", save_game)
	# Attempt to load game data when the SceneManager is ready
	load_game()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		print("saving...")
		save_game() # Call the save function
		get_tree().quit()
	#elif what == NOTIFICATION_DISABLED:
		## Also good practice to save when the application is requested to quit
		#save_game()
