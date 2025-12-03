extends NeighborFinder
class_name HorizontalVerticalFinder

const GridManager = preload("res://GridManager.gd")
var grid_manager: GridManager

func _init(manager: GridManager):
	grid_manager = manager

func get_neighbors(coord: Vector2i) -> Array[Vector2i]:
	var neighbors: Array[Vector2i] = []
	var directions = [Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 0), Vector2i(-1, 0)]
	
	for dir in directions:
		var neighbor_coord = coord + dir
		
		if grid_manager.is_valid_coord(neighbor_coord) and grid_manager.get_estado_celula(neighbor_coord) == GridManager.ESTADO_LIVRE:
			neighbors.append(neighbor_coord)
	return neighbors

func get_movement_cost(from: Vector2i, to: Vector2i) -> float:
	# Movimento horizontal ou vertical (custo 1.0)
	return 1.0
