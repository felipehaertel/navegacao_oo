extends NeighborFinder
class_name RectangularFinder

const GridManager = preload("res://GridManager.gd")
var grid_manager: GridManager

func _init(manager: GridManager):
	grid_manager = manager

func get_neighbors(coord: Vector2i) -> Array[Vector2i]:
	var neighbors: Array[Vector2i] = []
	for x in range(-1, 2):
		for y in range(-1, 2):
			if x == 0 and y == 0:
				continue
			
			var neighbor_coord = Vector2i(coord.x + x, coord.y + y)
			
			if grid_manager.is_valid_coord(neighbor_coord) and grid_manager.get_estado_celula(neighbor_coord) == GridManager.ESTADO_LIVRE:
				neighbors.append(neighbor_coord)
	return neighbors

func get_movement_cost(from: Vector2i, to: Vector2i) -> float:
	if from.x != to.x and from.y != to.y:
		# Movimento diagonal (sqrt(2) approx 1.414)
		return 1.414
	# Movimento horizontal ou vertical
	return 1.0
