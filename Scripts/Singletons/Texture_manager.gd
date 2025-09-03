extends Node

var chalk_line_org : Image
var ink_circle_org : Image

var chalk_line : Image
var ink_circle : Image
var resize_factor: int = 4

var surface_pos: Array[Vector2]

##save the drawing room active tool
var g_tool: int = 1
##save the summoning room active tool
var s_tool: int = 1
