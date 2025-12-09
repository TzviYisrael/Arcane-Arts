extends Control
@onready var content: RichTextLabel = $Background/VBoxContainer/content
@onready var circle_diagram: TextureRect = $CircleDiagram

func _ready() -> void:
	pass

func set_page_by_number(value: int, text: String) -> void:
	set_page_content(text)
	$Background/Number.text =  "- "+str(value) + " -"

func set_page_content(text: String) -> void:
	var result: Dictionary = parse_page_string(text)
	content.text = result.text_before
	if not result.elements.is_empty():
		set_circle_diagram(result.elements, result.canvas_size)
		if circle_diagram.texture:
			content.push_paragraph(HorizontalAlignment.HORIZONTAL_ALIGNMENT_CENTER)
			content.add_image(circle_diagram.texture, 0, 0)
			content.pop_all()
		else: print("missing tex"); circle_diagram.queue_redraw()
	content.append_text(result.text_after)

#new format:
#This is the first block of text data. It can contain multiple lines and normal punctuation.
#[cd=400,400]
#[line(-10,0,10,0)][circle(0,0,200)][dot(20,10,5,#ff0000)][symbol(20,100,π,10,#ffff00)]
#[/cd]
#This is the final block of text. We can use this to add captions or concluding remarks.

# New format structure:
# "[cd=width,height] [command(args)] [command(args)]... [/cd]"
func parse_page_string(data_string: String) -> Dictionary:
	# FIX 1: Initialize the result dictionary with the new "elements" structure
	var result: Dictionary = {
		"text_before": data_string.strip_edges(),
		"text_after": "",
		"canvas_size": Vector2.ZERO,
		"elements": {
			"line": [],
			"circle": [],
			"dot": [],
			"symbol": [],
		}
	}
	
	# --- TAGS/REGEX ---
	# ... (CD_BLOCK_REGEX and regex compilation remains the same)
	const CD_BLOCK_REGEX: String = "(?s)^(.*?)\\s*\\[cd=(\\d+),(\\d+)\\]\\s*(.*?)\\s*\\[/cd\\]\\s*(.*)$"
	var regex := RegEx.new()
	var error: Error = regex.compile(CD_BLOCK_REGEX)
	if error != OK:
		return result
		
	var cd_match: RegExMatch = regex.search(data_string.strip_edges())
	
	if cd_match:
		# --- 1. Extract and Assign Text Blocks & Canvas Size ---
		
		result.text_before = cd_match.get_string(1).strip_edges()
		result.text_after = cd_match.get_string(5).strip_edges()
		
		var width: float = float(cd_match.get_string(2))
		var height: float = float(cd_match.get_string(3))
		result.canvas_size = Vector2(width, height)
		
		var command_block: String = cd_match.get_string(4).strip_edges()
		
		# --- 2. Parse elements inside the block ---
		
		# Group 1: element name (e.g., line, circle, dot)
		# Group 2: Arguments string (e.g., -10,0,10,0)
		const COMMAND_TAG_REGEX: String = "\\[(\\w+)\\((.*?)\\)\\]"
		var command_regex := RegEx.new()
		error = command_regex.compile(COMMAND_TAG_REGEX)
		if error != OK:
			return result
			
		var command_matches: Array[RegExMatch] = command_regex.search_all(command_block)
		
		for cmd_match_entry: RegExMatch in command_matches:
			var command_type: String = cmd_match_entry.get_string(1).to_lower().strip_edges() # Use to_lower for dictionary keys
			
			# FIX 2: Store the raw argument string instead of parsing it
			var raw_args: String = cmd_match_entry.get_string(2).strip_edges()
			
			# FIX 3: Check if the command type is a key in the elements dictionary
			if result.elements.has(command_type):
				# FIX 4: Append the raw argument string to the corresponding list
				result.elements[command_type].append(raw_args)

	return result

#func parse_page_string(data_string: String) -> Dictionary:
	#var result: Dictionary = {
		#"text_before": data_string.strip_edges(),
		#"text_after": "",
		#"commands": []
	#}
	#
	## --- TAGS ---
	#const START_TAG = "[cd]"
	#const END_TAG = "[/cd]"
#
	#var start_pos: int = data_string.find(START_TAG)
	#var end_pos: int = data_string.find(END_TAG)
	#
	## Check if the image block is present and properly sequenced
	#if start_pos == -1 or end_pos == -1 or start_pos > end_pos:
		#return result
#
	## --- 1. Extract and Assign Text Blocks ---
	#
	#result.text_before = data_string.substr(0, start_pos).strip_edges()
	#result.text_after = data_string.substr(end_pos + END_TAG.length()).strip_edges()
#
	#var command_block: String = data_string.substr(start_pos + START_TAG.length(),
	   #end_pos - (start_pos + START_TAG.length())).strip_edges()
	#
	## --- 2. Parse Commands ---
	#
	#for command_entry in command_block.split("$", false):
		#var trimmed_line: String = command_entry.strip_edges()
		#if trimmed_line.is_empty(): continue
#
		## 2a. Split Command Type and Arguments (limit to 1 split)
		#var name_args: PackedStringArray = trimmed_line.split(":", false, 1)
		#if name_args.size() < 2: continue
			#
		#var command_type: String = name_args[0].strip_edges().to_upper()
		#
		#if command_type != "LINE" and command_type != "CIRCLE":
			#continue # Skip any other command type
			#
		#var raw_args: String = name_args[1].strip_edges()
#
		## 2b. Parse Coordinates (convert strings to integers)
		#var coords := []
		#for coord_str in raw_args.split(",", false):
			#var val: String = coord_str.strip_edges()
			#coords.append(float(val) if val.is_valid_float() else 0.0)
#
		## Append the parsed command
		#result.commands.append({
			#"type": command_type,
			#"coords": coords,
		#})
#
	#return result

func set_circle_diagram(elements: Dictionary, im_size: Vector2) -> void:
	circle_diagram.image_size = im_size
	circle_diagram.lines_strings.clear()
	circle_diagram.circles_strings.clear()
	circle_diagram.dots_strings.clear()
	circle_diagram.symbols_strings.clear()
	
	circle_diagram.lines_strings = elements.line
	circle_diagram.circles_strings = elements.circle
	circle_diagram.dots_strings = elements.dot
	circle_diagram.symbols_strings = elements.symbol
	circle_diagram.bake_drawing_to_texture()
