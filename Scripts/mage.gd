extends CharacterBody3D

@export var max_hp := 100
@export var max_mp := 100
@export var hp := 100
@export var mp := 100


@export var speed := 5.0
@export var acceleration := 5.0
@export var rot_speed := 8.0 # Increased rotation speed for smooth turning

@onready var model := $Rig
@onready var anim_tree := $AnimationTree
@onready var anim_state: AnimationNodeStateMachinePlayback = \
							 $AnimationTree.get("parameters/playback")
 
@onready var gpu_particles_3d: GPUParticles3D = $Rig/GPUParticles3D
@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var camera_spring_arm: SpringArm3D = $camera_spring_arm
@onready var camera_3d: Camera3D = $camera_spring_arm/Camera3D
@onready var camera_ray_cast: RayCast3D = $camera_spring_arm/RayCast3D

var target_rotation_y: float = -1.0 

func _ready() -> void:
	Signals.connect("spell_chanted", emit_spell)
	Signals.connect("mage_look", look)
	Signals.connect("walk_destination", set_walk_destination)
	Signals.connect("rotate_camera", rotate_camera)
	SceneManager.set_mage(self)

func _physics_process(delta: float) -> void:
	var destination: Vector3 = navigation_agent_3d.get_next_path_position()
	var local_destination: Vector3 = destination - global_position
	var direction: Vector3 = local_destination.normalized()
	var movement_direction: Vector3 = direction
	
	if not navigation_agent_3d.is_navigation_finished():
		velocity = movement_direction * speed
		rotate_camera(0.0)
	else:
		velocity = lerp(velocity, Vector3.ZERO, delta * 8.0)
		

	var target_yaw: float = model.rotation.y
	@warning_ignore("unused_variable")
	var rotation_active: bool = true
	
	if target_rotation_y != -1.0:
		target_yaw = target_rotation_y
		rotation_active = true
		
		if abs(model.rotation.y - target_yaw) < 0.01:
			model.rotation.y = target_yaw
			target_rotation_y = -1.0
			rotation_active = false
	
  
	elif velocity.length_squared() > 0.01:
		target_yaw = atan2(movement_direction.x, movement_direction.z) + PI
			
	model.rotation.y = lerp_angle(model.rotation.y, target_yaw, delta * rot_speed)
	
	var local_velocity: Vector3 = velocity * model.transform.basis
	anim_tree.set("parameters/IWR/blend_position",
	 Vector2(local_velocity.x, -local_velocity.z) / speed)
	
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		anim_state.travel("Spellcast_Shoot")
	if event.is_action_pressed("summon"):
		anim_state.travel("summon")

func set_walk_destination(dest: Vector3) -> void:
	navigation_agent_3d.target_position = dest

func set_rotation_smooth(new_yaw_radians: float) -> void:
	target_rotation_y = new_yaw_radians

func rotate_camera(angle: float) -> void:
	camera_spring_arm.rotate_y(angle)
	camera_ray_cast.target_position = camera_ray_cast.to_local(global_position)
	var collider: Object = camera_ray_cast.get_collider()
	if collider and collider.name.begins_with("wall"):
		Signals.emit_signal("hide_wall", collider.get_parent())
	else:
		Signals.emit_signal("hide_wall", null)

func look(pos: Vector3) -> void:
	var target_direction: Vector3 = pos - global_position
	var target_yaw: float = atan2(target_direction.x, target_direction.z) + PI
	
	set_rotation_smooth(target_yaw)

func emit_spell(spell: String) -> void:
	anim_state.travel("summon")
	for word: String in spell.split(" "):
		var time: float = len(word) * 0.2
		gpu_particles_3d.lifetime = time
		gpu_particles_3d.emitting = true
		await get_tree().create_timer(time).timeout
		gpu_particles_3d.emitting = false
