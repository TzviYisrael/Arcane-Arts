extends GutTest

var xy_sim: Image = preload("res://Test/unit_tests/xy_sim.png").get_image()
var y_sim: Image = preload("res://Test/unit_tests/y_sim.png").get_image()
var no_sim: Image = preload("res://Test/unit_tests/no_sim.png").get_image()

func before_all():
	gut.p("Runs once before all tests")

func test_is_mirror_symmetry_chatgpt():
	assert_eq(Ink_circle.is_mirror_symmetry(xy_sim), [true, true])
	
	assert_eq(Ink_circle.is_mirror_symmetry(y_sim), [false, true])
	
	assert_eq(Ink_circle.is_mirror_symmetry(no_sim), [false, false])

func test_ca():
	var img = Image.load_from_file("res://Test/unit_tests/small.png")
	for i in range(5):
		prints("test: ", i)
		Ink_circle.fast_ca_genretion(img)
		#img.save_png("res://Test/unit_tests/small.png")
		img.save_png("res://Test/unit_tests/small_after_%d.png" % i)

func test_rgb_c():
	assert_true(Ink_circle.compare_rgb(Color.BLACK, Color(0, 0, 0, 0)))
	assert_false(Ink_circle.compare_rgb(Color(1, 1, 1, 0), Color(1, 0, 1, 1)))
	assert_true(Ink_circle.compare_rgb(Color(1, 1, 1, 0), Color(1, 1, 1, 0.5)))

func after_all():
	gut.p(Ink_circle.count_color(xy_sim, Color.BLACK))
	gut.p(Ink_circle.count_color(xy_sim, Color.WHITE))
