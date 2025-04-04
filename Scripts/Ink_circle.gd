class_name Ink_circle

extends Object

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
			if x < width / 2:  # Horizontal check
				if img.get_pixel(x, y) == img.get_pixel(width - 1 - x, y):
					horizontal_matches += 1
			if y < height / 2:  # Vertical check
				if img.get_pixel(x, y) == img.get_pixel(x, height - 1 - y):
					vertical_matches += 1

	var horizontal_ratio = float(horizontal_matches) / (int(width / 2) * height)
	var vertical_ratio = float(vertical_matches) / (int(height / 2) * width)

	return [horizontal_ratio >= threshold, vertical_ratio >= threshold]
	
static func ca_genretion(img: Image) -> void:
	var width = img.get_width()
	var height = img.get_height()
	
	for y in range(height - 2):
		for x in range(width - 2):
			#var color := img.get_pixel(x + 1, y + 1)
			var c = img.get_pixel(x + 1, y).blend(
					img.get_pixel(x + 2, y + 1).blend(
					img.get_pixel(x + 1, y + 2).blend(
					img.get_pixel(x, y + 1))))
			img.set_pixel(x, y, c)
	print("done", randi())
