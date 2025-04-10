class_name Ink_circle

extends Object

static func resize_image(image: Image, factor: int) -> Image:
	var new_image := image.duplicate()
	var new_width := image.get_width() / float(factor)
	var new_height := image.get_height() / float(factor)
	new_image.resize(new_width, new_height, Image.INTERPOLATE_LANCZOS)
	return new_image

static func crop_image_to_circle(image: Image, radius_percentage: float) -> Image:
	var size = image.get_width()
	var image_center = Vector2(size / 2.0, size / 2.0)
	var radius = (size / 2.0) * radius_percentage
	
	# Ensure image has an alpha channel
	image.convert(Image.FORMAT_RGBA8)

	for y in range(size):
		for x in range(size):
			var pos = Vector2(x, y)
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

	var x_zero = pos.x - radius 
	var y_zero = pos.y - radius 
	for y in range(radius * 2.0):
		for x in range(radius * 2.0):
			if pos.distance_to(Vector2(x,y)) > radius:
				continue	
			var color1 := image1.get_pixel(x_zero + x, y_zero + y)
			var color2 := mask.get_pixel(x_zero + x, y_zero + y)
			if color2.a == 0.0 || color1 != Color.BLACK:
				result_image.set_pixel(x, y, Color(0, 0, 0, 0))
	return result_image

#static func init_ink_colors(img: Image) -> void:
	#if img.is_empty():
		#return
#
	#var width = img.get_width()
	#var height = img.get_height()
	#var border_color = Color.GREEN
	#var summon_color = Color.RED
	#
	##set the center pixel to red
	#for i in range(width / 2.0 - 5, width / 2.0 + 5):
		#for j in range(height / 2.0 - 5, height / 2.0 + 5):
			#img.set_pixel(i, j, summon_color)
	#
	## Top and bottom rows to green
	#for x in range(width):
		#img.set_pixel(x, 0, border_color) # Top
		#img.set_pixel(x, height - 1, border_color) # Bottom
#
	## Left and right columns to green
	#for y in range(1, height - 1): # Avoid corners (already set above)
		#img.set_pixel(0, y, border_color) # Left
		#img.set_pixel(width - 1, y, border_color) # Right
		
	#for y in range(height - 2):
		#for x in range(width - 2):
			#var this = img.get_pixel(x + 1, y + 1)
			#if this == Color.BLACK:
				#img.set_pixel(x, y, Color(this.r,this.g,this.b,this.a * SceneManager.mage_mana))
				#print(img.get_pixel(x, y))

static func init_ink_colors(img: Image) -> void:
	if img.is_empty():
		return

	var width = img.get_width()
	var height = img.get_height()
	var border_color = Color.GREEN
	var summon_color = Color.RED

	var center = Vector2(width / 2.0, height / 2.0)
	var radius = min(width, height) / 2.0 - 1.0

	# Draw center circle in red
	var inner_radius = 5.0
	for y in range(int(center.y - inner_radius), int(center.y + inner_radius) + 1):
		for x in range(int(center.x - inner_radius), int(center.x + inner_radius) + 1):
			var pos = Vector2(x, y)
			if center.distance_to(pos) <= inner_radius:
					img.set_pixel(x, y, summon_color)

	# Draw circular border in green using polar coordinates
	var steps = int(2 * PI * radius)  # Approximate number of pixels on the circle
	for i in range(steps):
		var angle = i * 2 * PI / steps
		var x = int(center.x + cos(angle) * radius)
		var y = int(center.y + sin(angle) * radius)

		# Ensure we're in bounds
		if x >= 0 and x < width and y >= 0 and y < height:
			img.set_pixel(x, y, border_color)


static func count_color(circle: Image, ink_color:Color):
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

static func ca_genretion(img: Image) -> bool:
	var buffer = img.duplicate()
	var width = img.get_width()
	var height = img.get_height()
	var changed: bool = false
	
	for y in range(height - 2):
		for x in range(width - 2):
			var this = buffer.get_pixel(x + 1, y + 1)
			if compare_rgb(this, Color.BLACK):
				if this.a <= 0.2:
					var nei = [buffer.get_pixel(x + 1, y),
							buffer.get_pixel(x + 2, y + 1),
							buffer.get_pixel(x + 1, y + 2),
							buffer.get_pixel(x, y + 1)]
					if Color.RED in nei:
						img.set_pixel(x + 1, y + 1, Color.RED)
						changed = true
					elif Color.GREEN in nei:
						img.set_pixel(x + 1, y + 1, Color.GREEN)
						changed = true
					continue  
				else:
					var nei = [buffer.get_pixel(x + 1, y),
							buffer.get_pixel(x + 2, y + 1),
							buffer.get_pixel(x + 1, y + 2),
							buffer.get_pixel(x, y + 1)]
					if Color.RED in nei:
						img.set_pixel(x + 1, y + 1, this - Color(0.0, 0.0, 0.0, 0.05))
						changed = true
						
	print("gen - ", Time.get_ticks_usec())
	return changed
	
static func fast_ca_genretion(img: Image) -> bool:
	if img == null:
		TextureManager.pos = []
	
	var buffer = img.duplicate()
	var width = img.get_width()
	var height = img.get_height()
	var is_in_border = func borders(v: Vector2) -> bool: return v == \
			v.clamp(Vector2.ZERO, Vector2(width - 1, height - 1))
	var changed: bool = false
	if TextureManager.pos.is_empty():
		for y in range(height - 2):
			for x in range(width - 2):
				var this = img.get_pixel(x + 1, y + 1)
				if compare_rgb(this, Color.BLACK):
					var nei = [buffer.get_pixel(x + 1, y),
							buffer.get_pixel(x + 2, y + 1),
							buffer.get_pixel(x + 1, y + 2),
							buffer.get_pixel(x, y + 1)]
					if Color.RED in nei or Color.GREEN in nei:
						TextureManager.pos.append(Vector2(x + 1, y + 1))
					continue
	else:
		var new_pos: Array[Vector2] = []
		for p in TextureManager.pos:
			var x = p.x
			var y = p.y
			#img.set_pixel(x, y, Color.PURPLE)
			var nei = [Vector2(x - 1, y), Vector2(x + 1, y),\
			 Vector2(x, y - 1), Vector2(x, y + 1)].filter(is_in_border)
			var this = buffer.get_pixelv(p)
			for n in nei:
				var n_color = buffer.get_pixelv(n)
				if compare_rgb(n_color, Color.BLACK): 
					if not n in new_pos:
						new_pos.append(n)
						
				if compare_rgb(n_color, Color.RED):
					if this.a > 0.2:
						img.set_pixelv(p, this - Color(0.0, 0.0, 0.0, 0.05))
					else:
						img.set_pixelv(p, Color.RED)
				elif compare_rgb(n_color, Color.GREEN):
					if this.a > 0.2:
						pass
					else:
						img.set_pixelv(p, Color.GREEN)
		
		TextureManager.pos = new_pos
		if new_pos.size() < 10: print(new_pos)
		print("pos size - ", TextureManager.pos.size())

	return true

static func compare_rgb(color1: Color, color2: Color = Color.BLACK):
	return color1.clamp(Color(0.,0.,0.,1.),Color(1.,1.,1.,1.)) == \
	color2.clamp(Color(0.,0.,0.,1.),Color(1.,1.,1.,1.))
	#return color1.r == color2.r && color1.g == color2.g && color1.b == color2.b
