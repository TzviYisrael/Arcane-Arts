extends GutTest

var xy_sim: Image = preload("res://Test/unit_tests/xy_sim.png").get_image()
var y_sim: Image = preload("res://Test/unit_tests/y_sim.png").get_image()
var no_sim: Image = preload("res://Test/unit_tests/no_sim.png").get_image()

func before_all() -> void:
	gut.p("Runs once before all tests")

func test_is_mirror_symmetry_chatgpt() -> void:
	assert_eq(Ink_circle.is_mirror_symmetry(xy_sim), [true, true])
	
	assert_eq(Ink_circle.is_mirror_symmetry(y_sim), [false, true])
	
	assert_eq(Ink_circle.is_mirror_symmetry(no_sim), [false, false])

func test_ca() -> void:
	var img := Image.load_from_file("res://Test/unit_tests/small.png")
	for i in range(5):
		prints("test: ", i)
		Ink_circle.fast_ca_genretion(img, 1)
		#img.save_png("res://Test/unit_tests/small.png")
		img.save_png("res://Test/unit_tests/small_after_%d.png" % i)
	assert_true(true)

func test_flood_fill() -> void:
	var img := Image.load_from_file("res://Test/unit_tests/flood_img.png")
	assert_eq(len(Ink_circle.flood_fill(img, Vector2(4, 0), false)), 9, "the fill is incorrect")
	assert_eq(Ink_circle.flood_fill(img, Vector2(3, 0), false), [Vector2(3,0)], "the fill is incorrect")
	assert_eq(Ink_circle.flood_fill(img, Vector2(-1, -1), false), [], "not empty in OOB position")

func test_island_counter() -> void:
	var img := Image.load_from_file("res://Test/unit_tests/flood_img.png")
	assert_eq(Ink_circle.island_counter(img, 0, false), 6)

func test_find_center() -> void:
	var img := Image.load_from_file("res://Test/unit_tests/flood_img.png")
	assert_eq(Ink_circle.find_center(Ink_circle.flood_fill(img, Vector2(2, 2), false)), Vector2(2, 2))

func test_rgb_c() -> void:
	assert_true(Ink_circle.compare_rgb(Color.BLACK, Color(0, 0, 0, 0)))
	assert_false(Ink_circle.compare_rgb(Color(1, 1, 1, 0), Color(1, 0, 1, 1)))
	assert_true(Ink_circle.compare_rgb(Color(1, 1, 1, 0), Color(1, 1, 1, 0.5)))

func after_all() -> void:
	gut.p(Ink_circle.count_color(xy_sim, Color.BLACK))
	gut.p(Ink_circle.count_color(xy_sim, Color.WHITE))
