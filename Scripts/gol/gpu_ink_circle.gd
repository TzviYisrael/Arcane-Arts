extends Sprite3D

# We'll give input to the first renderer
# Then the CA (Cellular Automata) will ping-pong
# back and forth between the two viewports
@onready var Renderer := $Viewport/Renderer

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


#func _process(_delta: float) -> void:
	#Renderer.material.set_shader_parameter("mouse_position", pos + pos_offset)
	#Renderer.material.set_shader_parameter("mouse_pressed", true)
	#
	#pos_offset += Vector2.ONE
	#if pos_offset > Vector2(253, 253):
		#pos_offset = Vector2(-253, -253)

func set_ca_texture(tex: Texture2D) -> void:
	print("set_gpu_ink_circle")
	Renderer.update(tex)
	Renderer.material.set_shader_parameter("run", true)
	await get_tree().process_frame
	Renderer.material.set_shader_parameter("run", false)

func _on_change_ca_state(run: bool) -> void:
	print("run? ", run)
	Renderer.material.set_shader_parameter("run", run)
