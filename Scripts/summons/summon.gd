extends CharacterBody3D

class_name Summon

@export var hp = 100
@export var mp = 100
@export var power = 10000

enum CATEGORY{ANIMAL, MONSTER, DEMON}
@export_enum ("animal", "monster", "demon") var category: int

var mage: Node3D

func _ready():
	mage = SceneManager.mage


func _process(_delta: float):
	pass

func take_damage(amount: int):
	hp -= amount
	if hp <= 0:
		die()

func die():
	queue_free()
