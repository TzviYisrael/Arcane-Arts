extends Sprite3D

# We'll give input to the first renderer
# Then the CA (Cellular Automata) will ping-pong
# back and forth between the two viewports
@onready var Renderer := $Viewport/Renderer
@onready var Renderer2: Sprite2D = $Viewport2/Renderer

@onready var pixel_reducer: Sprite2D = $pixel_reducer
@onready var filter_sprite: Sprite2D = $pixel_reducer/level_0_vp/level0_sp

@export var start_texture: Texture2D


var pos := Vector2(253, 253)
var pos_offset := Vector2.ZERO

func _ready() -> void:
	Signals.connect("change_ca_state", _on_change_ca_state)
	# We've turned off the viewport rendering in the
	# Godot editor to improve battery life & development time
	#
	# Here we enable it again when we load the viewport in game
	$Viewport.set_update_mode(SubViewport.UPDATE_ALWAYS)
	$Viewport2.set_update_mode(SubViewport.UPDATE_ALWAYS)

	if not Renderer:
		print("Could not mount renderer")
		return
	Renderer.material.set_shader_parameter("mouse_position", pos)
	
	set_ca_texture(start_texture)

#
#func _process(_delta: float) -> void:
	#Renderer.material.set_shader_parameter("mouse_position", pos + pos_offset)
	#Renderer.material.set_shader_parameter("mouse_pressed", true)
	#
	#pos_offset += Vector2.ONE
	#if pos_offset > Vector2(253, 253):
		#pos_offset = Vector2(-253, -253)

func count_color(color: Color) -> void:
	filter_sprite.material.set_shader_parameter("target_color", color)
	await RenderingServer.frame_post_draw
	
	var small_img: Image = pixel_reducer.texture.get_image()
	var height : int = small_img.get_height()
	var width : int = small_img.get_width()
	
	var sum : float = 0
	var n : int = height * width
	for y in range(height):
		for x in range(width):
			sum += small_img.get_pixel(x, y).r
	print((sum / n) * 255)
	
func save_small_image() -> void:
	var save_path: String = "res://GameData/small_img.png"
	var small_img: Image = pixel_reducer.texture.get_image()
	print("saving... ", small_img)
	small_img.save_png(save_path)
		
func one_shot_shader(shader_material: ShaderMaterial, delay: int) -> void:
	var original_material: Material = Renderer.material
	
	Renderer.material = shader_material
	Renderer2.material = shader_material
	for i in range(delay):
		await get_tree().process_frame
	Renderer.material = original_material
	await get_tree().process_frame
	Renderer2.material = original_material


func set_ca_texture(tex: Texture2D) -> void:
	#print("set_gpu_ink_circle ", tex)
	Renderer.setup(tex)
	Renderer2.setup(tex)
	await get_tree().process_frame
	Renderer.setup_loop()
	Renderer2.setup_loop()
	
	Renderer.material.set_shader_parameter("run", false)

func _on_change_ca_state(run: bool) -> void:
	#print("change ca state: ", run)
	Renderer.material.set_shader_parameter("run", run)
