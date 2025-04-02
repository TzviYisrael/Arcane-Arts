extends GutTest

var texture: Image

func before_all():
	texture = preload("res://Test/inq.png").get_image()
	gut.p("Runs once before all tests")

func test_evaluate_circle():
	assert_eq(1,1)
