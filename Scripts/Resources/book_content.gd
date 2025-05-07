extends Resource
class_name BookContent

@export var pages: Array[String]


func get_page(page_number: int) -> String:
	var num_of_pages: int = len(pages)
	#prints(num_of_pages, page_number)
	if page_number < 0 or page_number >= num_of_pages:
		printerr("book out of bound")
		return "out of bound"
	return pages[page_number]
