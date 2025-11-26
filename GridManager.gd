extends RefCounted
class_name GridManager

const ESTADO_LIVRE: int = 0
const ESTADO_OCUPADO: int = 1

var grid: Array = [] 
var num_celulas_x: int = 0
var num_celulas_y: int = 0
var tamanho_celula: int = 64

# Método de inicialização que popula o grid
func inicializar_grid(x: int, y: int, cel_size: int):
	num_celulas_x = x
	num_celulas_y = y
	tamanho_celula = cel_size
	
	grid.clear()
	for row_y in range(num_celulas_y):
		var linha: Array = []
		for col_x in range(num_celulas_x):
			linha.append(ESTADO_LIVRE) 
		grid.append(linha)

# --- NOVO MÉTODO (NECESSÁRIO PELO ADAPTER) ---
# Verifica se as coordenadas estão dentro dos limites do grid.
func is_valid_coord(coord: Vector2i) -> bool:
	return coord.x >= 0 and coord.x < num_celulas_x and \
		   coord.y >= 0 and coord.y < num_celulas_y

# Métodos de acesso para desacoplar a cena dos dados
func get_estado_celula(coord: Vector2i) -> int:
	# O Adapter (Finder) deve usar is_valid_coord antes de chamar esta função, 
	# mas esta checagem garante que não haja erro de índice se chamada diretamente.
	if not is_valid_coord(coord):
		return -1 # Fora dos limites
	return grid[coord.y][coord.x]

func set_estado_celula(coord: Vector2i, estado: int):
	if is_valid_coord(coord):
		grid[coord.y][coord.x] = estado
