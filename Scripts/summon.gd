extends CharacterBody3D

class_name Summon

@export var hp = 100
@export var mp = 100
@export var power = 10000
@export var player: Node3D  # Drag and drop the player in the Inspector

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func take_damage(amount: int):
	hp -= amount
	if hp <= 0:
		die()

func die():
	queue_free()
