extends CharacterBody3D

@export var max_hp := 100
@export var max_mp := 100
@export var hp := 100
@export var mp := 100

@export var speed := 8.0
@export var rot_speed := 8.0

@onready var model := $Rig
@onready var anim_tree := $AnimationTree
@onready var anim_state: AnimationNodeStateMachinePlayback = $AnimationTree.get("parameters/playback")
@onready var particles: GPUParticles3D = $Rig/GPUParticles3D
@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D

@onready var cam_arm: SpringArm3D = $camera_spring_arm
@onready var camera: Camera3D = $camera_spring_arm/Camera3D
@onready var cam_cast: ShapeCast3D = $camera_spring_arm/Camera3D/ShapeCast3D 
@onready var shader_mesh: MeshInstance3D = $camera_spring_arm/Camera3D/shader_mesh

var last_cam_angle: float = 0.0
var forced_yaw: float = INF # INF means "no forced rotation"

func _ready() -> void:
	Signals.connect("spell_chanted", cast_spell)
	Signals.connect("mage_look", on_look)
	Signals.connect("walk_destination", set_destination)
	Signals.connect("rotate_camera", rotate_cam)
	Signals.connect("summon_effect", show_summon_fx)
	
	SceneManager.set_mage(self)
	shader_mesh.mesh.material.set_shader_parameter("summon_effect", 1.0)
	cam_arm.rotation_degrees = SceneManager.camera_rot_deg

func _physics_process(delta: float) -> void:
	# 1. Handle Movement
	var next_pos: Vector3 = navigation_agent_3d.get_next_path_position()
	var dir: Vector3 = (next_pos - global_position).normalized()
	
	if not navigation_agent_3d.is_navigation_finished():
		velocity = dir * speed
		rotate_cam(0.0)
		# FIX: If player moves, cancel the "Look at" lock immediately
		forced_yaw = INF 
	else:
		velocity = lerp(velocity, Vector3.ZERO, delta * 8.0)

	# 2. Handle Rotation
	var current_yaw: float = model.rotation.y
	var target_yaw: float = current_yaw # Default: Stay as is

	if forced_yaw != INF:
		# Case A: We are forced to look at a target
		target_yaw = forced_yaw
		# FIX: If we are close enough to the target angle, stop forcing it
		if abs(angle_difference(current_yaw, forced_yaw)) < 0.05:
			forced_yaw = INF
	elif velocity.length_squared() > 0.1:
		# Case B: We are moving, look at movement direction
		target_yaw = atan2(velocity.x, velocity.z) + PI

	# Apply smooth rotation
	model.rotation.y = lerp_angle(current_yaw, target_yaw, delta * rot_speed)
	
	# 3. Handle Animation
	var local_vel: Vector3 = velocity * model.transform.basis
	anim_tree.set("parameters/IWR/blend_position", Vector2(local_vel.x, -local_vel.z) / speed)
	
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		anim_state.travel("Spellcast_Shoot")
	if event.is_action_pressed("summon"):
		anim_state.travel("summon")

# --- Actions ---

func set_destination(dest: Vector3) -> void:
	navigation_agent_3d.target_position = dest

func on_look(pos: Vector3) -> void:
	var dir: Vector3 = pos - global_position
	# Calculates the angle to the target
	forced_yaw = atan2(dir.x, dir.z) + PI

func rotate_cam(angle: float) -> void:
	cam_arm.rotate_y(angle)
	SceneManager.camera_rot_deg = cam_arm.rotation_degrees
	
	if abs(last_cam_angle - cam_arm.rotation_degrees.y) > 15:
		Signals.emit_signal("hide_wall", null)
		last_cam_angle = cam_arm.rotation_degrees.y
		
	for i: int in cam_cast.get_collision_count():
		var collider: Object = cam_cast.get_collider(i)
		if collider and collider.name.begins_with("wall"):
			Signals.emit_signal("hide_wall", collider.get_parent())

# --- Visual Effects ---

func show_summon_fx() -> void:
	var mat: ShaderMaterial = shader_mesh.mesh.material
	var tween := create_tween()
	tween.tween_property(mat, "shader_parameter/summon_effect", 0.0, 0.6)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.chain().tween_property(mat, "shader_parameter/summon_effect", 1.0, 0.01)\
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)

func cast_spell(spell: String) -> void:
	anim_state.travel("summon")
	for word: String in spell.split(" "):
		var time: float = len(word) * 0.2
		particles.lifetime = time
		particles.emitting = true
		await get_tree().create_timer(time).timeout
		particles.emitting = false
