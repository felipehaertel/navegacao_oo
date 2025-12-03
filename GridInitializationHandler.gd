extends InitializerHandler
class_name GridInitializationHandler

const GridManager = preload("res://GridManager.gd")

var viewport_size: Vector2
var cell_size: int

func _init(v_size: Vector2, c_size: int):
	super._init()
	viewport_size = v_size
	cell_size = c_size

func handle_initialization(context: Dictionary) -> bool:
	print("CoR: Inicializando GridManager...")
	
	var grid_manager = GridManager.new()
	var num_cells_x = int(viewport_size.x / cell_size)
	var num_cells_y = int(viewport_size.y / cell_size)
	
	grid_manager.initialize_grid(num_cells_x, num_cells_y, cell_size)
	
	context["grid_manager"] = grid_manager
	context["cell_size"] = cell_size
	
	return true
