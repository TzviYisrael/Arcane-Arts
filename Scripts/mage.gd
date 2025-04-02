extends CharacterBody3D

@export var max_hp = 100
@export var max_mp = 100
@export var hp = 100
@export var mp = 100

@export var speed = 5.0
@export var acceleration = 5.0
@export var rot_speed = 5.0

@onready var spring_arm = $SpringArm3D
@onready var model = $Rig
@onready var anim_tree = $AnimationTree
@onready var anim_state = $AnimationTree.get("parameters/playback")

func cast():
	var fire_ball_scene = preload("res://Scenes/fireball.tscn")
	var fireball = fire_ball_scene.instantiate()
	fireball.position = model.position + Vector3(0.0, 1.5, 0.0)
	fireball.dir = -model.global_transform.basis.z
	fireball.speed = 0.5
	add_child(fireball)


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	get_move_input(delta)
	move_and_slide()

func get_move_input(delta):
	if velocity.length() > 1.0:
		model.rotation.y = lerp_angle(model.rotation.y, spring_arm.rotation.y, rot_speed * delta)
	
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var cam_rot = Input.get_vector("ui_left", "ui_right", "null", "null").x
	var angle = deg_to_rad(cam_rot)
	spring_arm.rotate_y(angle)
	
	var direction = Vector3(input_dir.x, 0, input_dir.y).normalized().rotated(Vector3.UP, spring_arm.rotation.y)
	velocity = lerp(velocity, direction * speed, acceleration * delta)
	
	var vl = velocity * model.transform.basis
	anim_tree.set("parameters/IWR/blend_position", Vector2(vl.x, -vl.z) / speed)

func _unhandled_input(event):
	if event.is_action_pressed("attack"):
		anim_state.travel("Spellcast_Shoot")
		cast()
	if event.is_action_pressed("summon"):
		anim_state.travel("summon")
		Signals.emit_signal("start_summon")
