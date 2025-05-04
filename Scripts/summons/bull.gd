extends "res://Scripts/summons/summon.gd"

var distance_to_mage: int = 100

func _ready() -> void:
	pass # Replace with function body.

func _process(_delta: float) -> void:
	if mage:
		distance_to_mage = global_position.distance_to(mage.global_position)
		
		if distance_to_mage < 8:
			look_at(mage.position)
