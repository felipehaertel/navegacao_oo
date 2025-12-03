extends RefCounted
class_name GridManager

const ESTADO_LIVRE = 0
const ESTADO_OCUPADO = 1

var grid_data: Dictionary = {}
var num_celulas_x: int = 0
var num_celulas_y: int = 0
var tamanho_celula: int = 0

func initialize_grid(x: int, y: int, c_size: int):
	num_celulas_x = x
	num_celulas_y = y
	tamanho_celula = c_size
	
	for i in range(x):
		for j in range(y):
			grid_data[Vector2i(i, j)] = ESTADO_LIVRE

func get_estado_celula(coord: Vector2i) -> int:
	if grid_data.has(coord):
		return grid_data[coord]
	return ESTADO_OCUPADO 

func set_estado_celula(coord: Vector2i, estado: int):
	if grid_data.has(coord):
		grid_data[coord] = estado

func is_valid_coord(coord: Vector2i) -> bool:
	return coord.x >= 0 and coord.x < num_celulas_x and coord.y >= 0 and coord.y < num_celulas_y
