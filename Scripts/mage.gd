extends CharacterBody3D

@export var max_hp := 100
@export var max_mp := 100
@export var hp := 100
@export var mp := 100

@export var speed := 5.0
@export var acceleration := 5.0
@export var rot_speed := 5.0

@onready var spring_arm := $SpringArm3D
@onready var model := $Rig
@onready var anim_tree := $AnimationTree
@onready var anim_state: AnimationNodeStateMachinePlayback = \
						$AnimationTree.get("parameters/playback")

enum CAMERA_STATES{ROOM, SUMMONING, OFFSIDE}
var camera_state: int = CAMERA_STATES.ROOM:
	set(new_state):
		camera_state_exit(camera_state)
		camera_state = new_state
		camera_state_enter(camera_state)
	get: return camera_state

var fire_ball_scene: Resource

func  _ready() -> void:
	SceneManager.set_mage(self)
	fire_ball_scene = load("res://Scenes/fireball.tscn")

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	get_move_input(delta)
	move_and_slide()

func get_move_input(delta: float) -> void:
	if velocity.length() > 1.0:
		model.rotation.y = lerp_angle(model.rotation.y, spring_arm.rotation.y, rot_speed * delta)
	
	var input_dir: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	var direction := Vector3(input_dir.x, 0, input_dir.y).normalized().rotated(Vector3.UP, spring_arm.rotation.y)
	velocity = lerp(velocity, direction * speed, acceleration * delta)
	
	if input_dir != Vector2.ZERO: camera_state = CAMERA_STATES.ROOM
	var vl: Vector3 = velocity * model.transform.basis
	anim_tree.set("parameters/IWR/blend_position", Vector2(vl.x, -vl.z) / speed)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		anim_state.travel("Spellcast_Shoot")
		cast()
	if event.is_action_pressed("summon"):
		anim_state.travel("summon")
		#Signals.emit_signal("start_summon")
		
func rotate_camera(deg: float) -> void:
	var angle: float = deg_to_rad(deg)
	spring_arm.rotate_y(angle)

func cast() -> void:
	var fireball: Node = fire_ball_scene.instantiate()
	fireball.position = model.position + Vector3(0.0, 1.5, 0.0)
	fireball.dir = -model.global_transform.basis.z
	fireball.speed = 0.5
	add_child(fireball)

func camera_state_exit(CAMERA_STATE: int) -> void:
	var tween := create_tween()
	
	match CAMERA_STATE:
		CAMERA_STATES.ROOM: tween.tween_method(func do_nothing(_a: int) -> void: pass, 0, 0, 1)
		CAMERA_STATES.SUMMONING: 
			tween.tween_property(spring_arm, "rotation_degrees:x", -20, 0.5)
		CAMERA_STATES.OFFSIDE: 
			tween.tween_property(spring_arm, "position:x", 0, 0.5)
func camera_state_enter(CAMERA_STATE: int) -> void: 
	var tween := create_tween()
	match CAMERA_STATE:
		CAMERA_STATES.ROOM: tween.tween_method(func do_nothing(_a: int) -> void: pass, 0, 0, 1)
		CAMERA_STATES.SUMMONING: 
			tween.tween_property(spring_arm, "rotation_degrees:x", -40, 0.5)
		CAMERA_STATES.OFFSIDE: 
			tween.tween_property(spring_arm, "position:x", 2, 0.5)
