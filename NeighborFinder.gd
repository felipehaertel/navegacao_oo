extends RefCounted
class_name NeighborFinder

# Adaptador: Define a interface para encontrar vizinhos
func get_neighbors(coord: Vector2i) -> Array[Vector2i]:
	push_error("Método 'get_neighbors' não implementado.")
	return []

# Adaptador: Define o custo de movimento entre dois pontos
func get_movement_cost(from: Vector2i, to: Vector2i) -> float:
	push_error("Método 'get_movement_cost' não implementado.")
	return INF
