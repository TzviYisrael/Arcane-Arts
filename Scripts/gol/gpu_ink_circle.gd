extends Sprite3D
class_name GPU_Ink_Circle

# We'll give input to the first renderer
# Then the CA (Cellular Automata) will ping-pong
# back and forth between the two viewports
@onready var Renderer := $CA_Display/Viewport/Renderer
@onready var Renderer2: Sprite2D = $CA_Display/Viewport2/Renderer2

@onready var ca_display: Sprite3D = $CA_Display

@onready var pixel_reducer: Sprite2D = $CA_Display/pixel_reducer
@onready var filter_sprite: Sprite2D = $CA_Display/pixel_reducer/level_0_vp/level0_sp

@export var start_texture: Texture2D

@onready var init_material: ShaderMaterial = load("res://Assets/shaders/init.tres")
@onready var clear_material: ShaderMaterial = load("res://Assets/shaders/clear.tres")

@onready var gpu_particles_3d: GPUParticles3D = $GPUParticles3D

func _ready() -> void:
	Signals.connect("change_ca_state", _on_change_ca_state)
	Signals.connect("summon_particles", summon_particles)
	# We've turned off the viewport rendering in the
	# Godot editor to improve battery life & development time
	#
	# Here we enable it again when we load the viewport in game
	$CA_Display/Viewport.set_update_mode(SubViewport.UPDATE_ALWAYS)
	$CA_Display/Viewport2.set_update_mode(SubViewport.UPDATE_ALWAYS)

	if not Renderer:
		print("Could not mount renderer")
		return	
	set_ca_texture(start_texture)

func init() -> void:
	var positions_array: Array[Vector2]
	var colors_array: Array[Color]
	for pos: Vector2 in SceneManager.placed_item:
		var item: Item = SceneManager.placed_item[pos]
		positions_array.append(pos)
		colors_array.append(item.color)
	init_material.set_shader_parameter("circle_count", positions_array.size())
	init_material.set_shader_parameter("circle_positions", positions_array)
	init_material.set_shader_parameter("circle_colors", colors_array)
	
	one_shot_shader(init_material, 1)
	#await get_tree().process_frame

func count_color(color: Color) -> int:
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
	return ((sum / n) * 255)
	
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

func clear_colors() -> void:
	one_shot_shader(clear_material, 10)
	await get_tree().process_frame
	
func summon_particles(target: Vector3) -> void:
	var particle_process_material: ShaderMaterial = gpu_particles_3d.process_material
	particle_process_material.set_shader_parameter("target_position", target)
	gpu_particles_3d.emitting = true
