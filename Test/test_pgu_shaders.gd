extends Node3D

@onready var ink_circle: GPU_Ink_Circle = $ink_circle

@export var init_texture: Texture2D

# MUST MATCH SHADER! If shader uses 64, this must be 64.
const MAX_TYPES = 64 

var reaction_image: Image
var reaction_texture: ImageTexture

# Define your IDs here to match your logic
enum {AIR, WATER, LAVA, STONE, ACID}

# Assuming you have your colors defined somewhere. 
# If not, define them here for safety:
var my_colors_array: Array[Color] = [
	Color(0, 0, 0, 0),    # AIR (ID 0)
	Color(0, 0, 1, 1),    # WATER (ID 1)
	Color(1, 0, 0, 1),    # LAVA (ID 2)
	Color(0.5, 0.5, 0.5), # STONE (ID 3)
	Color(0, 1, 0, 1)     # ACID (ID 4)
	# ... fill up to 64 if needed or ensure MAX_TYPES matches array size
]

func _ready() -> void:
	ink_circle.process_mode = Node.PROCESS_MODE_INHERIT
	
	# 1. Initialize the textures immediately
	init_system()

func init_system() -> void:
	# Generate the 3 Textures needed by the shader
	
	# A. Reaction Table (Logic)
	set_reaction_texture() 
	
	# B. 3D LUT (Input: Color -> ID)
	var lut_texture: ImageTexture3D = create_3d_lut(my_colors_array)
	
	# C. 1D Palette (Output: ID -> Color) <-- THIS WAS MISSING
	var palette_texture: ImageTexture = create_palette_texture(my_colors_array)
	
	# Initialize the simulation
	ink_circle.set_ca_texture(init_texture)
	
	# Send ALL 3 textures to the shader
	Signals.emit_signal("set_shader_textures", 
		reaction_texture, 
		lut_texture, 
		palette_texture
	)

func set_reaction_texture() -> void:
	reaction_image = Image.create(MAX_TYPES, MAX_TYPES, false, Image.FORMAT_RGBAF)
	
	# --- DEFINE RULES ---
	set_reaction(LAVA, WATER, STONE, 1, 0.0) # Lava touches Water -> Stone
	set_reaction(WATER, LAVA, STONE, 1, 0.0) # Water touches Lava -> Stone
	set_reaction(STONE, ACID, AIR, 2, 0.5)   # Stone touches Acid -> Air (Decay)
	
	reaction_texture = ImageTexture.create_from_image(reaction_image)

func set_reaction(me_id: int, neighbor_id: int, result_id: int, type: int, speed: float) -> void:
	# FIXED MATH: Use the same "Center of Pixel" logic as the LUT
	var id_value := (float(result_id) + 0.5) / float(MAX_TYPES)
	
	var color := Color(
		id_value,            # R: Target ID
		float(type) / 10.0,  # G: Type
		speed,               # B: Speed
		1.0
	)
	reaction_image.set_pixel(neighbor_id, me_id, color)

# --- MISSING FUNCTION ADDED HERE ---
func create_palette_texture(colors: Array[Color]) -> ImageTexture:
	# This creates the strip that tells the shader "ID 0.1 is Red"
	var width: int = MAX_TYPES # Use MAX_TYPES to ensure alignment
	var image := Image.create(width, 1, false, Image.FORMAT_RGBAF)
	
	for i in range(colors.size()):
		image.set_pixel(i, 0, colors[i])
		
	return ImageTexture.create_from_image(image)

func create_3d_lut(palette_colors: Array[Color]) -> ImageTexture3D:
	var size: int = 32
	var slices: Array[Image] = []

	# 1. Create 32 empty slices (This represents the Z axis)
	for i in range(size):
		# Create a 32x32 image for this slice
		var img := Image.create(size, size, false, Image.FORMAT_RGBAF)
		# Initialize to ID 0 (Air/Empty)
		img.fill(Color(0.0, 0.0, 0.0, 0.0))
		slices.append(img)

	# 2. Paint our known colors onto the correct slices
	for id_index: int in range(palette_colors.size()):
		var col: Color = palette_colors[id_index]

		# Map Color channels (0.0 - 1.0) to Coordinates (0 - 31)
		var x := int(col.r * (size - 1))
		var y := int(col.g * (size - 1))
		var z := int(col.b * (size - 1))

		# Encode the ID to point to the CENTER of the palette pixel
		var stored_id_value := (float(id_index) + 0.5) / float(MAX_TYPES)
		var stored_health := 1.0

		# Write to the specific slice (Z) at position (X, Y)
		slices[z].set_pixel(x, y, Color(stored_id_value, stored_health, 0.0, 1.0))

	# 3. Create the 3D Texture from the array of slices
	var tex_3d := ImageTexture3D.new()
	# Args: Format, Width, Height, Depth, Mipmaps, Data(Array of Images)
	tex_3d.create(Image.FORMAT_RGBAF, size, size, size, false, slices)
	
	return tex_3d

func start_ritual(_category: int) -> void:
	ink_circle.init()
	await get_tree().process_frame
	print("start ritual")
	Signals.emit_signal("change_ca_state", true)

func clean_texture() -> void:
	ink_circle.clear_colors()
	print("clear")

func _on_start_button_pressed() -> void:
	start_ritual(0)

func _on_clear_button_pressed() -> void:
	clean_texture()
	ink_circle.set_ca_texture(init_texture)
	Signals.emit_signal("change_ca_state", false)
