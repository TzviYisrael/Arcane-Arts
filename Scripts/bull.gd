extends "res://Scripts/summon.gd"

var distance_to_player = 100
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player:
		distance_to_player = global_position.distance_to(player.global_position)
		#print("Distance to player: ", distance_to_player)
		
		if distance_to_player < 8:
			look_at(player.position)
