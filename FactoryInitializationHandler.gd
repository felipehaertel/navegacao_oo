extends InitializerHandler
class_name FactoryInitializationHandler

# Importa as classes
const AgenteFactory = preload("res://AgenteFactory.gd")
const EstaticoFactory = preload("res://EstaticoFactory.gd") 
const RectangularFinder = preload("res://RectangularFinder.gd")
const AgentLifecycleObserver = preload("res://AgentLifecycleObserver.gd") 

var parent_node: Node2D

func _init(parent: Node2D):
	super._init()
	parent_node = parent

func handle_initialization(context: Dictionary) -> bool:
	print("CoR: Inicializando Factories e Adapters...")

	var grid_manager = context["grid_manager"]
	
	var neighbor_finder = RectangularFinder.new(grid_manager) 
	var path_point_factory = EstaticoFactory.new()
	var lifecycle_observer = AgentLifecycleObserver.new(parent_node)

	var agent_factory = AgenteFactory.new(parent_node, grid_manager, neighbor_finder, lifecycle_observer)
	
	context["neighbor_finder"] = neighbor_finder
	context["path_point_factory"] = path_point_factory
	context["agent_factory"] = agent_factory
	
	return true
