extends AspectRatioContainer

@export var item: Item
@onready var button: TextureButton = $Button
@onready var texture_rect: TextureRect = $TextureRect
@onready var name_label: Label = $NameLabel
@onready var amount_label: Label = $AmountLabel

func _ready() -> void:
	pass # Replace with function body.

func init_item(new_item: Item) -> void:
	item = new_item
	texture_rect.texture = item.icon
	name_label.text = item.name
	update_amount()
	

func update_amount() -> void:
	var amount: int = SceneManager.inventory[item.name]
	#print(amount)
	amount_label.text = str(amount)
	if amount <= 0:
		modulate = Color(1.0, 1.0, 1.0, 0.5)
	else:
		modulate = Color(1.0, 1.0, 1.0, 1.0)
	

func item_botton_pressed() -> void:
	if SceneManager.current_room == SceneManager.SUMMON_FLOOR:
		var amount: int = SceneManager.inventory[item.name]
		if amount >= 1:
			Signals.emit_signal("add_to_inventory", item.name, -1) 
			Signals.emit_signal("item_moved", item)
