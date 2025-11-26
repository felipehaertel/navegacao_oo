extends NeighborFinder

# Constantes de direção para 4 vizinhos (apenas H/V)
const DIRECTIONS: Array[Vector2i] = [
	Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 0), Vector2i(-1, 0) # Apenas H/V
]

# Método principal do Adapter: encontra apenas vizinhos H/V
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
	# O movimento é sempre 1.0, pois este Finder só permite H/V
	# Se o GridAStar tentar usar uma coordenada diagonal,
	# ela não deve estar na lista retornada por get_neighbors,
	# mas por segurança, se a diferença for 1.0 (H/V), o custo é 1.0.
	
	# Verificamos se o movimento é H/V (diferença de 1 em X ou Y, mas não em ambos)
	if (abs(from_coord.x - to_coord.x) == 1 and abs(from_coord.y - to_coord.y) == 0) or \
	   (abs(from_coord.x - to_coord.x) == 0 and abs(from_coord.y - to_coord.y) == 1):
		return 1.0
	else:
		# Isso nunca deve acontecer se get_neighbors for chamado corretamente
		return INF
