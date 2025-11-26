extends NeighborFinder

# Constantes de direção para 8 vizinhos (incluindo diagonais)
const DIRECTIONS: Array[Vector2i] = [
	Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 0), Vector2i(-1, 0), # H/V
	Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1)  # Diagonais
]

# Método principal do Adapter: encontra todos os vizinhos (inclui H/V e Diagonais)
func get_neighbors(coord: Vector2i) -> Array:
	var vizinhos: Array = []
	
	for dir in DIRECTIONS:
		var vizinho_coord: Vector2i = coord + dir
		
		# USANDO O SINGLETON/GRIDMANAGER CORRETAMENTE
		# 1. Verifica se a coordenada está dentro dos limites do grid (CORREÇÃO)
		if grid_manager.is_valid_coord(vizinho_coord):
			# 2. Verifica se a célula não é um obstáculo
			if grid_manager.get_estado_celula(vizinho_coord) == GridManager.ESTADO_LIVRE:
				vizinhos.append(vizinho_coord)
				
	return vizinhos

# Retorna o custo de movimento
func get_movement_cost(from_coord: Vector2i, to_coord: Vector2i) -> float:
	# Verifica se o movimento é diagonal
	if abs(from_coord.x - to_coord.x) == 1 and abs(from_coord.y - to_coord.y) == 1:
		return 1.414 # Custo para diagonal (sqrt(2))
	else:
		return 1.0 # Custo para Horizontal/Vertical
