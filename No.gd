extends RefCounted
class_name No

var coord: Vector2i 
var g_custo: float = INF 
var h_custo: float = 0.0
var f_custo: float = INF 
var pai: No = null

func _init(c: Vector2i):
	coord = c
