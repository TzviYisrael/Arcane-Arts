extends CharacterBody3D

@export var max_hp := 100
@export var max_mp := 100
@export var hp := 100
@export var mp := 100

@export var speed := 5.0
@export var acceleration := 5.0
@export var rot_speed := 5.0

@onready var model := $Rig
@onready var anim_tree := $AnimationTree
@onready var anim_state: AnimationNodeStateMachinePlayback = \
						$AnimationTree.get("parameters/playback")
@onready var gpu_particles_3d: GPUParticles3D = $Rig/GPUParticles3D
@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D

func  _ready() -> void:
	Signals.connect("spell_chanted", emit_spell)
	Signals.connect("walk_destination", set_walk_destination)
	SceneManager.set_mage(self)

func _physics_process(delta: float) -> void:
	var destination: Vector3 = navigation_agent_3d.get_next_path_position()
	var local_destination: Vector3 = destination - global_position
	var direction: Vector3 = local_destination.normalized()
	if not navigation_agent_3d.is_navigation_finished():
		velocity = direction * speed
	else:
		velocity = lerp(velocity, Vector3.ZERO, delta * 8.0)
	
	var target_yaw: float = atan2(direction.x, direction.z) + PI
	model.rotation.y = lerp_angle(model.rotation.y, target_yaw, delta * 8.0)
	
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

func emit_spell(spell: String) -> void:
	anim_state.travel("summon")
	for word: String in spell.split(" "):
		var time: float = len(word) * 0.2
		gpu_particles_3d.lifetime = time
		gpu_particles_3d.draw_pass_1.text = word
		gpu_particles_3d.emitting = true
		await get_tree().create_timer(time).timeout
		gpu_particles_3d.emitting = false
