extends Node

var items_data: Dictionary
var items_file_path: String = "res://GameData/json/item.json"

var items_icons_dir: String = "res://Assets/textures/items/"
var items_models_dir: String = "res://Assets/models/items/"

var summons_data: Dictionary
var summons_file_path: String = "res://GameData/json/summons.json"

var summons_models_dir: String = "res://Assets/models/summons/"

var books_data: Dictionary
var books_file_path: String = "res://GameData/json/books.json"

var books_icons_dir: String = "res://Assets/textures/books/"

func _ready() -> void:
	items_data = load_items_from_json(items_file_path)
	print("game data loaded...")
	
	#for i: String in items_data.keys():
		#prints(items_data[i].name, items_data[i].icon, items_data[i].model)
	

## Loads items from a JSON file and returns a dictionary of Item resources.
func load_items_from_json(path: String) -> Dictionary:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("Cannot open JSON file: %s" % path)
		return {}
	
	var json_text: String = file.get_as_text()
	file.close()
	
	var json_parser := JSON.new()
	var error: Error = json_parser.parse(json_text)
	
	if error != OK:
		var error_line: int = json_parser.get_error_line()
		var error_message: String = json_parser.get_error_message()
		push_error("Failed to parse JSON at line %d: %s" % [error_line, error_message])
		return {}
		
	var data: Dictionary = json_parser.data
	var items: Dictionary = {}
	
	for item_name: String in data.keys():
		var item_data: Dictionary = data[item_name]
		
		var item := Item.new()
		
		item.name = item_name
		
		match item_data.get("origin", 0):
			0, "0": item.origin = Item.NATURAL
			1, "1": item.origin = Item.MYSTIC 
			2, "2": item.origin = Item.DEMONIC
			_: item.origin = Item.NATURAL 
		
		var icon_path: String = items_icons_dir + item_data.get("icon", "")
		if not icon_path.is_empty() and ResourceLoader.exists(icon_path):
			item.icon = ResourceLoader.load(icon_path, "Texture2D") 
			if item.icon == null:
				push_warning("Failed to load icon for '%s' from path: %s" % [item_name, icon_path])
		elif not icon_path.is_empty():
			push_warning("Icon not found for '%s': %s" % [item_name, icon_path])
			
		# Color
		var color_str: String = item_data.get("color", "#ffffff")
		if color_str.is_valid_html_color():
			item.color = Color(color_str)
		else:
			push_warning("Invalid color string for '%s': %s" % [item_name, color_str])
			item.color = Color("#ffffff")
			
		var model_path: String = items_models_dir + item_data.get("model", "")
		if not model_path.is_empty() and ResourceLoader.exists(model_path):
			item.model = ResourceLoader.load(model_path, "PackedScene")
			if item.model == null:
				push_warning("Failed to load model for '%s' from path: %s" % [item_name, model_path])
		elif not model_path.is_empty():
			push_warning("Model not found for '%s': %s" % [item_name, model_path])
			
		items[item_name] = item
			
	return items
