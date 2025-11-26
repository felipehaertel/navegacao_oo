extends RefCounted
class_name NeighborFinder

var grid_manager: GridManager

func _init(manager: GridManager):
	grid_manager = manager

# Métodos que devem ser sobrescritos pelos Adapters concretos
# Retorna um Array de Vector2i (coordenadas dos vizinhos válidos)
func get_neighbors(coord: Vector2i) -> Array:
	push_error("Método 'get_neighbors' não implementado na classe base.")
	return []

# Retorna o custo de movimento entre duas células (float)
func get_movement_cost(from_coord: Vector2i, to_coord: Vector2i) -> float:
	push_error("Método 'get_movement_cost' não implementado na classe base.")
	return INF
