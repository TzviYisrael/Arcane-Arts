extends Area3D

@export var dir = Vector3()
@export var speed = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	position += (dir * speed)

func _on_body_entered(body: Node3D) -> void:
	if(body.name == "Bull"):
		print("Bull")
