class_name Ink_circle

extends Object

@export var something := 5 # only to see it in the editor

static func resize_image(image: Image, factor: int) -> Image:
	var new_image := image.duplicate()
	var new_width := image.get_width() / float(factor)
	var new_height := image.get_height() / float(factor)
	new_image.resize(new_width, new_height, Image.INTERPOLATE_LANCZOS)
	return new_image

static func crop_image_to_circle(image: Image, radius_percentage: float) -> Image:
	var size: float = image.get_width()
	var image_center := Vector2(size / 2.0, size / 2.0)
	var radius: float = (size / 2.0) * radius_percentage
	
	# Ensure image has an alpha channel
	image.convert(Image.FORMAT_RGBA8)

	for y in range(size):
		for x in range(size):
			var pos := Vector2(x, y)
			if pos.distance_to(image_center) > radius:
				image.set_pixel(x, y, Color(0, 0, 0, 0))  # Make it transparent

	return image

static func mask_image(img: Image, mask: Image) -> Image:
	if mask == null:
		mask = img.duplicate()
	if img.get_size() != mask.get_size():
		push_error("Images must be the same size")
		return img.duplicate()  # Return a copy of the first image as a fallback

	var result_image := img.duplicate()

	for y in range(img.get_height()):
		for x in range(img.get_width()):
			var color_img := img.get_pixel(x, y)
			var color_mask := mask.get_pixel(x, y)
			if color_mask.a == 0.0 or color_img == Color.WHITE:
				result_image.set_pixel(x, y, Color(0, 0, 0, 0))
	
	return result_image

static func mask_circle(image1: Image, mask: Image, pos: Vector2, radius: float) -> Image:
	if mask == null:
		mask = image1.duplicate() 
	if image1.get_size() != mask.get_size():
		push_error("Images must be the same size")
		return image1.duplicate()  # Return a copy of the first image as a fallback

	var result_image := image1.duplicate()

	var x_zero: float = pos.x - radius 
	var y_zero: float = pos.y - radius 
	for y in range(radius * 2.0):
		for x in range(radius * 2.0):
			if pos.distance_to(Vector2(x,y)) > radius:
				continue	
			var color1 := image1.get_pixel(x_zero + x, y_zero + y)
			var color2 := mask.get_pixel(x_zero + x, y_zero + y)
			if color2.a == 0.0 || color1 != Color.BLACK:
				result_image.set_pixel(x, y, Color(0, 0, 0, 0))
	return result_image

static func init_ink_colors(img: Image) -> void:
	if img.is_empty():
		return

	var width: float = img.get_width()
	var height: float = img.get_height()
	var outside_color := Color.GREEN
	var portal_color := Color.DARK_BLUE
	var summon_color := Color.RED # remove?

	var center := Vector2(width / 2.0, height / 2.0)
	var radius: float = min(width, height) / 2.0 - 1.0

	# Draw center circle in red
	var inner_radius: float = 5.0
	for y in range(int(center.y - inner_radius), int(center.y + inner_radius) + 1):
		for x in range(int(center.x - inner_radius), int(center.x + inner_radius) + 1):
			var pos := Vector2(x, y)
			if center.distance_to(pos) <= inner_radius:
					img.set_pixel(x, y, portal_color)

	# Draw circular border in green using polar coordinates
	var steps := int(2 * PI * radius)  # Approximate number of pixels on the circle
	for i in range(steps):
		var angle = i * 2 * PI / steps
		var x = int(center.x + cos(angle) * radius)
		var y = int(center.y + sin(angle) * radius)

		# Ensure we're in bounds
		if x >= 0 and x < width and y >= 0 and y < height:
			img.set_pixel(x, y, outside_color)

static  func clean_colors(img: Image) -> void:
	if img.is_empty():
		return

	var width = img.get_width()
	var height = img.get_height()
	for y in range(height):
			for x in range(width):
				if not compare_rgb(img.get_pixel(x, y), Color.BLACK):
					img.set_pixel(x, y, Color(0.0,0.0,0.0,0.0))

static func count_color(circle: Image, ink_color:Color) -> int:
	var ink_counter := 0
	if circle == null:
		return 0
	for y in range(circle.get_height()):
		for x in range(circle.get_width()):
			if ink_color == circle.get_pixel(x, y):
				ink_counter += 1
	return ink_counter

static func is_mirror_symmetry(img: Image, threshold: float = 1.0) -> Array[bool]:
	if img.is_empty():
		return [false, false]  # No symmetry for empty images

	var width = img.get_width()
	var height = img.get_height()
	
	var horizontal_matches = 0
	var vertical_matches = 0

	for y in range(height):
		for x in range(width):
			if x < width / 2.0:  # Horizontal check
				if img.get_pixel(x, y) == img.get_pixel(width - 1 - x, y):
					horizontal_matches += 1
			if y < height / 2.0:  # Vertical check
				if img.get_pixel(x, y) == img.get_pixel(x, height - 1 - y):
					vertical_matches += 1

	var horizontal_ratio = float(horizontal_matches) / (int(width / 2.0) * height)
	var vertical_ratio = float(vertical_matches) / (int(height / 2.0) * width)

	return [horizontal_ratio >= threshold, vertical_ratio >= threshold]

static func fast_ca_genretion(img: Image, state: int) -> bool:
	var COLOR_STEP: float = 0.01
	var power: int = 0
	var changed: bool = false
	
	var outside_color := Color.GREEN
	var portal_color := Color.DARK_BLUE
	var summon_color := Color.RED
	
	if img == null:
		TextureManager.surface_pos = []
	
	var buffer: Image = img.duplicate()
	var width: float = img.get_width()
	var height: float = img.get_height()
	
	var center := Vector2(int(width / 2), int(height / 2))
	var radius: float = height / 2
	
	## check if the image boreders and in side the circle
	var is_in_border = func borders(v: Vector2) -> bool: 
		return center.distance_to(v) <= radius - 0.5

	if TextureManager.surface_pos.is_empty():
		for y in range(height):
			for x in range(width):
				if not compare_rgb(buffer.get_pixel(x, y), Color.BLACK):
					continue
				var nei = [Vector2(x - 1, y), Vector2(x + 1, y),\
			 		Vector2(x, y - 1), Vector2(x, y + 1)].filter(is_in_border).map(buffer.get_pixelv)
				#prints(x, y, nei, Color.RED in nei, Color.GREEN in nei)
				if portal_color in nei or outside_color in nei or summon_color in nei:
						TextureManager.surface_pos.append(Vector2(x, y))
						
		return not TextureManager.surface_pos.is_empty()
	
	else:
		for p in TextureManager.surface_pos:
			var x = p.x
			var y = p.y
			var p_color = buffer.get_pixelv(p)
			var new_color = p_color
			var nei = [Vector2(x - 1, y), Vector2(x + 1, y),\
			 		Vector2(x, y - 1), Vector2(x, y + 1)].filter(is_in_border).map(buffer.get_pixelv)
			if state == 0:
				if portal_color in nei:
					new_color = portal_color
					power += 1
					changed = true
					if Color.BLACK in nei: 
							Signals.emit_signal("portal_done", p)
							return true
			else:
				if p_color.a < COLOR_STEP * 2:
					if summon_color in nei or portal_color in nei:
						new_color = summon_color
						power += 1
						changed = true
						if outside_color in nei: 
							Signals.emit_signal("breach", p)
							return false
					elif outside_color in nei:
						new_color = outside_color
						changed = true
					
				else:
					if summon_color in nei:
						new_color = new_color - Color(0.0, 0.0, 0.0, COLOR_STEP)
						changed = true
				
			img.set_pixelv(p, new_color)
			
		
		var new_surface_pos: Array[Vector2] = []
		for p in TextureManager.surface_pos:
			var x = p.x
			var y = p.y
			if compare_rgb(img.get_pixelv(p), Color.BLACK):
				if not p in new_surface_pos: new_surface_pos.append(p)
				continue
			var nei = [Vector2(x - 1, y), Vector2(x + 1, y),\
			 		Vector2(x, y - 1), Vector2(x, y + 1)].filter(is_in_border)
			for n in nei:
				if compare_rgb(img.get_pixelv(n), Color.BLACK):
					if not n in new_surface_pos: new_surface_pos.append(n)

		if new_surface_pos.is_empty():
			TextureManager.surface_pos = []
			return changed
		else:
			#for p in TextureManager.surface_pos:
				#img.set_pixelv(p, img.get_pixelv(p).blend(Color(0.627451, 0.12549, 0.941176, 0.75)))
			TextureManager.surface_pos = new_surface_pos
			#print("surface_pos size: ", TextureManager.surface_pos.size())
			Signals.emit_signal("add_summon_power", power)
			#power = 0
			return changed

static func compare_rgb(color1: Color, color2: Color = Color.BLACK) -> bool:
	return color1.clamp(Color(0.0, 0.0, 0.0, 1.0),Color(1.0, 1.0, 1.0, 1.0)) == \
	color2.clamp(Color(0.0, 0.0, 0.0, 1.0),Color(1.0, 1.0, 1.0, 1.0))
