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

func after_all():
	gut.p(Ink_circle.count_color(xy_sim, Color.BLACK))
	gut.p(Ink_circle.count_color(xy_sim, Color.WHITE))
