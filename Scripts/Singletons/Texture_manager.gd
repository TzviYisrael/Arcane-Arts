extends Node

var resize_factor: int = 4 # the 2d version are 'resize_factor' bigger

var surface_pos: Array[Vector2] # to be removed 

#main room
var chalk_line: Image
var ink_circle: Image

#drawing desk
var chalk_line_2d: Image
##save the drawing desk active tool
var g_tool: int = 1 # need to changed

#summoning floor
var ink_circle_2d: Image
