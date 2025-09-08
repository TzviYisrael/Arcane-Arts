extends Control

var is_dragging: bool
@export var items: Array[Item]

@onready var natural: GridContainer = $natural
@onready var mystic: GridContainer = $mystic
@onready var demonic: GridContainer = $demonic

func _ready() -> void:
	for it in items:
		var button := Button.new()
		button.text = it.name
		button.connect("button_down", item_botton_pressed.bind(it))
		match it.origin:
			0:
				natural.add_child(button)
			1:
				mystic.add_child(button)
			2:
				demonic.add_child(button)

func _process(_delta: float) -> void:
	if is_dragging:
		print("draging")
		
func item_botton_pressed(item: Item) -> void:
	Signals.emit_signal("item_moved", item)
