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

var fire_ball_scene: Resource

func  _ready() -> void:
	Signals.connect("spell_chanted", emit_spell)
	SceneManager.set_mage(self)
	fire_ball_scene = load("res://Scenes/fireball.tscn")

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	get_move_input(delta)
	move_and_slide()

func get_move_input(delta: float) -> void:
	var input_dir: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	var direction := Vector3(input_dir.x, 0, input_dir.y).normalized()
	velocity = lerp(velocity, direction * speed, acceleration * delta)
	
	var vl: Vector3 = velocity * model.transform.basis
	anim_tree.set("parameters/IWR/blend_position", Vector2(vl.x, -vl.z) / speed)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		anim_state.travel("Spellcast_Shoot")
		cast()
	if event.is_action_pressed("summon"):
		anim_state.travel("summon")
		#Signals.emit_signal("start_summon")
		
func cast() -> void:
	var fireball: Node = fire_ball_scene.instantiate()
	fireball.position = model.position + Vector3(0.0, 1.5, 0.0)
	fireball.dir = -model.global_transform.basis.z
	fireball.speed = 0.5
	add_child(fireball)

func emit_spell(spell: String) -> void:
	for word: String in spell.split(" "):
		var time: float = len(word) * 0.2
		gpu_particles_3d.lifetime = time
		gpu_particles_3d.draw_pass_1.text = word
		gpu_particles_3d.emitting = true
		await get_tree().create_timer(time).timeout
		gpu_particles_3d.emitting = false
