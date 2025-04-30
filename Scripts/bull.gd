extends "res://Scripts/summon.gd"

var distance_to_mage = 100


func _ready():
	pass # Replace with function body.

func _process(_delta):
	if mage:
		distance_to_mage = global_position.distance_to(mage.global_position)
		
		if distance_to_mage < 8:
			look_at(mage.position)
