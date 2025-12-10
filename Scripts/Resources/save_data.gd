extends Resource
class_name SaveData

# --- Global & Dynamic Data ---

# Global (Godot automatically serializes Dictionary)
@export var inventory: Dictionary[String, int] = {}

# Mage (Vector3 is automatically serialized)
@export var camera_rot_deg: Vector3 = Vector3(-30.0, 0.0, 0.0)

# Main Room
@export var mage_pos: Vector3 = Vector3(10, 0.192, -5)
@export var mage_rot: Vector3 = Vector3(0.0, 0.0, 0.0)

# Placed Item data: Stored as an Array of Dictionaries for robust saving.
# Each dictionary contains the item's position (Vector2) and its ID (String).
@export var placed_item_data: Array[Dictionary] = [] # Format: [{'pos': Vector2, 'id': String}]

# Drawing Desk
@export var drawing_desk_current_tool: int = 1

# Summoning Floor
@export var summoning_floor_brush_size: float = 0.29
@export var summoning_floor_current_tool: int = 1

# UI
# Corresponds to the index of the enum {MAIN=0, SUMMON_FLOOR=1, DRAWING_DESK=2}
@export var current_room: int = 0 
@export var current_book_name: String = ""

# --- Texture Manager Dynamic Data (Saved as PNG-encoded PackedByteArray) ---
# This keeps the image data contained within the resource file, avoiding separation.

@export var chalk_line_data: PackedByteArray = PackedByteArray()
@export var ink_circle_data: PackedByteArray = PackedByteArray()
@export var chalk_line_2d_data: PackedByteArray = PackedByteArray()
@export var ink_circle_2d_data: PackedByteArray = PackedByteArray()
